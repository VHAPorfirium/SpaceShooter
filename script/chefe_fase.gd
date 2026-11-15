class_name ChefeBase
extends Area2D

## Base comum dos chefes: entrada, vida, etapas e os ataques reaproveitáveis.
## Cada chefe só decide QUANDO usar cada ataque, em _atualizar() e _ao_mudar_etapa().

signal vida_mudou(vida: int, vida_maxima: int)
signal derrotado(pontos: int, posicao: Vector2)
signal disparou(posicao: Vector2, direcao: Vector2)
signal aviso_iniciado  # o chefe vai fazer um ataque forte (telegrafar)
signal etapa_mudou(etapa_atual: int, total_de_etapas: int)
signal invocacao_solicitada(dados: DadosInimigo, posicao: Vector2)

const LIMITE_ESQUERDO_DA_PATRULHA := 60.0
const LIMITE_DIREITO_DA_PATRULHA := 420.0

@export var nome: String = "Chefe"
@export var vida_maxima: int = 50
@export var pontos: int = 300
@export var altura_parada: float = 110.0
## Arte do chefe, uma por etapa (a Colmeia tem 3; os outros, 1). Vazio = desenho geométrico.
@export var texturas_por_etapa: Array[Texture2D] = []
## Versão "acesa" da arte, uma por etapa, alternada com a normal durante o aviso de ataque.
@export var texturas_de_aviso_por_etapa: Array[Texture2D] = []
## Frações da vida em que o chefe passa para a próxima etapa.
## Ex.: [0.66, 0.33] = 3 etapas (troca com 66% e com 33% da vida). Vazio = 1 etapa.
@export var limites_das_etapas: Array[float] = []

var vida: int
var entrando: bool = true
var etapa_atual: int = 1

var _direcao_da_patrulha: float = 1.0


func _ready() -> void:
	add_to_group("chefe")
	vida = vida_maxima
	area_entered.connect(_ao_receber_area)
	$Imagem.exibir(_textura_da_etapa(texturas_por_etapa), $Forma.shape.size, [$Desenho])
	vida_mudou.emit(vida, vida_maxima)


func _process(delta: float) -> void:
	if entrando:
		position.y = move_toward(position.y, altura_parada, 90.0 * delta)
		if is_equal_approx(position.y, altura_parada):
			entrando = false
		return
	_atualizar(delta)


func total_de_etapas() -> int:
	return limites_das_etapas.size() + 1


# --- Pontos de extensão para cada chefe -------------------------------------

func _atualizar(_delta: float) -> void:
	pass  # cada chefe define o seu comportamento


func _ao_mudar_etapa(_nova_etapa: int) -> void:
	pass  # chefes com etapas trocam o padrão de ataque aqui


# --- Ataques reaproveitáveis -------------------------------------------------

func _patrulhar_horizontalmente(delta: float, velocidade: float) -> void:
	position.x += _direcao_da_patrulha * velocidade * delta
	if position.x > LIMITE_DIREITO_DA_PATRULHA:
		position.x = LIMITE_DIREITO_DA_PATRULHA
		_direcao_da_patrulha = -1.0
	elif position.x < LIMITE_ESQUERDO_DA_PATRULHA:
		position.x = LIMITE_ESQUERDO_DA_PATRULHA
		_direcao_da_patrulha = 1.0


## Vários tiros abertos para baixo, como um leque. abertura_radianos é o ângulo de cada lado.
func _atirar_leque(quantidade_de_tiros: int, abertura_radianos: float, distancia_da_boca: float) -> void:
	for indice in quantidade_de_tiros:
		var fracao := 0.5 if quantidade_de_tiros == 1 else float(indice) / (quantidade_de_tiros - 1)
		var angulo := lerpf(-abertura_radianos, abertura_radianos, fracao)
		disparou.emit(global_position + Vector2(0.0, distancia_da_boca), Vector2.DOWN.rotated(angulo))


## Tiros mirados no jogador, com pequenos desvios para os lados.
func _atirar_rajada_mirada(desvios_radianos: Array[float], distancia_da_boca: float) -> void:
	var direcao_base := Vector2.DOWN
	var jogador := _jogador()
	if jogador != null:
		direcao_base = (jogador.global_position - global_position).normalized()
	for desvio in desvios_radianos:
		disparou.emit(global_position + Vector2(0.0, distancia_da_boca), direcao_base.rotated(desvio))


func _posicao_x_do_jogador_dentro_da_patrulha() -> float:
	var jogador := _jogador()
	if jogador == null:
		return position.x
	return clampf(jogador.global_position.x, LIMITE_ESQUERDO_DA_PATRULHA, LIMITE_DIREITO_DA_PATRULHA)


## Pisca o chefe antes de um ataque forte: alterna entre a arte normal e a de aviso
## (ou, no plano B, entre a cor base e a cor de aviso do desenho).
func _piscar_aviso(tempo_restante: float, cor_base: Color, cor_aviso: Color) -> void:
	var aceso := int(tempo_restante * 14.0) % 2 == 0
	if $Imagem.usa_textura():
		var textura_de_aviso := _textura_da_etapa(texturas_de_aviso_por_etapa)
		var deve_mostrar_aviso := aceso and textura_de_aviso != null
		$Imagem.trocar_textura(textura_de_aviso if deve_mostrar_aviso else _textura_da_etapa(texturas_por_etapa))
	else:
		$Desenho.color = cor_aviso if aceso else cor_base


## Volta ao visual normal da etapa atual (fim do aviso ou troca de etapa).
func _restaurar_visual(cor_base: Color) -> void:
	if $Imagem.usa_textura():
		$Imagem.trocar_textura(_textura_da_etapa(texturas_por_etapa))
	else:
		$Desenho.color = cor_base


func _textura_da_etapa(texturas: Array[Texture2D]) -> Texture2D:
	if texturas.is_empty():
		return null
	return texturas[clampi(etapa_atual - 1, 0, texturas.size() - 1)]


func _jogador() -> Node2D:
	return get_tree().get_first_node_in_group("jogador") as Node2D


# --- Dano e etapas -----------------------------------------------------------

func _ao_receber_area(area: Area2D) -> void:
	area.queue_free()  # o tiro some ao acertar
	if entrando or vida <= 0:
		return  # invulnerável durante a entrada
	vida -= 1
	vida_mudou.emit(vida, vida_maxima)
	if vida <= 0:
		derrotado.emit(pontos, global_position)
		queue_free()
		return
	_verificar_troca_de_etapa()


func _verificar_troca_de_etapa() -> void:
	var etapa_pela_vida := 1
	var fracao_da_vida := float(vida) / vida_maxima
	for limite in limites_das_etapas:
		if fracao_da_vida <= limite:
			etapa_pela_vida += 1
	if etapa_pela_vida > etapa_atual:
		etapa_atual = etapa_pela_vida
		etapa_mudou.emit(etapa_atual, total_de_etapas())
		_ao_mudar_etapa(etapa_atual)
