extends ChefeBase

## Colmeia (Fase 3), a Nave-Mãe. Três etapas, ligadas à vida restante:
##   Etapa 1: patrulha e atira em leque.
##   Etapa 2: chama Batedores e solta tiros mirados.
##   Etapa 3: rajadas miradas e investidas combinadas.
## Todo ataque forte é avisado antes (a nave pisca e toca o alarme).

enum Estado { ATACANDO, AVISANDO, INVESTINDO, RETORNANDO, TROCANDO_DE_ETAPA }

const BATEDOR := preload("res://data/batedor.tres")

const COR_POR_ETAPA := {1: Color("#9b5de5"), 2: Color("#d63384"), 3: Color("#ff3b3b")}
const COR_AVISO := Color("#ffffff")
const CENTRO_DA_TELA_X := 240.0
const DISTANCIA_DA_BOCA := 44.0
const POSICOES_DE_INVOCACAO: Array[Vector2] = [Vector2(-70, 40), Vector2(0, 56), Vector2(70, 40)]
const DESVIOS_DA_RAJADA_FINAL: Array[float] = [-0.3, -0.15, 0.0, 0.15, 0.3]
const DESVIO_DO_TIRO_UNICO: Array[float] = [0.0]

@export_group("Etapa 1: leque")
@export var velocidade_etapa_1: float = 100.0
@export var intervalo_leque: float = 2.2
@export var tiros_no_leque: int = 7

@export_group("Etapa 2: invocação")
@export var velocidade_etapa_2: float = 60.0
@export var intervalo_invocacao: float = 4.0
@export var intervalo_tiro_mirado: float = 1.5

@export_group("Etapa 3: investidas e rajadas")
@export var velocidade_etapa_3: float = 110.0
@export var rajadas_antes_da_investida: int = 2
@export var intervalo_rajada: float = 0.8
@export var velocidade_investida: float = 560.0
@export var velocidade_retorno: float = 160.0
@export var altura_investida: float = 600.0
@export var intervalo_tiro_no_retorno: float = 0.5

@export_group("Comum")
@export var tempo_aviso: float = 0.8
@export var duracao_troca_de_etapa: float = 1.2

var _estado: Estado = Estado.ATACANDO
var _tempo_ate_o_ataque: float = 1.5
var _tempo_ate_o_tiro_secundario: float = 0.0
var _tempo_no_estado: float = 0.0
var _rajadas_feitas: int = 0
var _alvo_x_da_investida: float = CENTRO_DA_TELA_X


func _ready() -> void:
	nome = "Colmeia"
	vida_maxima = 160
	pontos = 1000
	altura_parada = 155.0
	limites_das_etapas.assign([0.66, 0.33])
	super()
	$Desenho.polygon = PackedVector2Array([
		Vector2(-64, -6), Vector2(-44, -34), Vector2(-14, -40), Vector2(14, -40),
		Vector2(44, -34), Vector2(64, -6), Vector2(48, 24), Vector2(18, 30),
		Vector2(0, 44), Vector2(-18, 30), Vector2(-48, 24)])
	$Desenho.color = _cor_da_etapa()


func _atualizar(delta: float) -> void:
	match _estado:
		Estado.TROCANDO_DE_ETAPA:
			_atualizar_troca_de_etapa(delta)
		Estado.AVISANDO:
			_atualizar_aviso(delta)
		Estado.INVESTINDO:
			_atualizar_investida(delta)
		Estado.RETORNANDO:
			_atualizar_retorno(delta)
		Estado.ATACANDO:
			match etapa_atual:
				1: _atualizar_etapa_1(delta)
				2: _atualizar_etapa_2(delta)
				_: _atualizar_etapa_3(delta)


func _ao_mudar_etapa(_nova_etapa: int) -> void:
	# Volta ao topo, pisca e avisa antes de mudar o padrão
	_estado = Estado.TROCANDO_DE_ETAPA
	_tempo_no_estado = duracao_troca_de_etapa
	aviso_iniciado.emit()


# --- Etapa 1: leque ----------------------------------------------------------

func _atualizar_etapa_1(delta: float) -> void:
	_patrulhar_horizontalmente(delta, velocidade_etapa_1)
	_tempo_ate_o_ataque -= delta
	if _tempo_ate_o_ataque <= 0.0:
		_tempo_ate_o_ataque = intervalo_leque
		_iniciar_aviso()


# --- Etapa 2: invocação de Batedores ----------------------------------------

func _atualizar_etapa_2(delta: float) -> void:
	_patrulhar_horizontalmente(delta, velocidade_etapa_2)
	_tempo_ate_o_tiro_secundario -= delta
	if _tempo_ate_o_tiro_secundario <= 0.0:
		_tempo_ate_o_tiro_secundario = intervalo_tiro_mirado
		_atirar_rajada_mirada(DESVIO_DO_TIRO_UNICO, DISTANCIA_DA_BOCA)
	_tempo_ate_o_ataque -= delta
	if _tempo_ate_o_ataque <= 0.0:
		_tempo_ate_o_ataque = intervalo_invocacao
		_iniciar_aviso()


func _invocar_batedores() -> void:
	for deslocamento in POSICOES_DE_INVOCACAO:
		invocacao_solicitada.emit(BATEDOR, global_position + deslocamento)


# --- Etapa 3: rajadas e investidas ------------------------------------------

func _atualizar_etapa_3(delta: float) -> void:
	_patrulhar_horizontalmente(delta, velocidade_etapa_3)
	_tempo_ate_o_ataque -= delta
	if _tempo_ate_o_ataque > 0.0:
		return
	if _rajadas_feitas < rajadas_antes_da_investida:
		_atirar_rajada_mirada(DESVIOS_DA_RAJADA_FINAL, DISTANCIA_DA_BOCA)
		_rajadas_feitas += 1
		_tempo_ate_o_ataque = intervalo_rajada
	else:
		_rajadas_feitas = 0
		_alvo_x_da_investida = _posicao_x_do_jogador_dentro_da_patrulha()
		_iniciar_aviso()


func _atualizar_investida(delta: float) -> void:
	position.y += velocidade_investida * delta
	if position.y >= altura_investida:
		position.y = altura_investida
		_estado = Estado.RETORNANDO
		_tempo_ate_o_tiro_secundario = 0.0


func _atualizar_retorno(delta: float) -> void:
	# Na volta, continua atirando no jogador: investida e rajada combinadas
	position.y = move_toward(position.y, altura_parada, velocidade_retorno * delta)
	_tempo_ate_o_tiro_secundario -= delta
	if _tempo_ate_o_tiro_secundario <= 0.0:
		_tempo_ate_o_tiro_secundario = intervalo_tiro_no_retorno
		_atirar_rajada_mirada(DESVIO_DO_TIRO_UNICO, -DISTANCIA_DA_BOCA)
	if is_equal_approx(position.y, altura_parada):
		_estado = Estado.ATACANDO
		_tempo_ate_o_ataque = 1.0


# --- Aviso e troca de etapa --------------------------------------------------

func _iniciar_aviso() -> void:
	_estado = Estado.AVISANDO
	_tempo_no_estado = tempo_aviso
	aviso_iniciado.emit()


func _atualizar_aviso(delta: float) -> void:
	_tempo_no_estado -= delta
	_piscar_aviso(_tempo_no_estado, _cor_da_etapa(), COR_AVISO)
	if etapa_atual >= 3:
		position.x = move_toward(position.x, _alvo_x_da_investida, 240.0 * delta)
	if _tempo_no_estado > 0.0:
		return
	_restaurar_visual(_cor_da_etapa())
	_executar_ataque_avisado()


func _executar_ataque_avisado() -> void:
	match etapa_atual:
		1:
			_atirar_leque(tiros_no_leque, 0.7, DISTANCIA_DA_BOCA)
			_estado = Estado.ATACANDO
		2:
			_invocar_batedores()
			_estado = Estado.ATACANDO
		_:
			_estado = Estado.INVESTINDO


func _atualizar_troca_de_etapa(delta: float) -> void:
	_tempo_no_estado -= delta
	position.y = move_toward(position.y, altura_parada, velocidade_retorno * delta)
	position.x = move_toward(position.x, CENTRO_DA_TELA_X, 120.0 * delta)
	_piscar_aviso(_tempo_no_estado, _cor_da_etapa(), COR_AVISO)
	if _tempo_no_estado <= 0.0 and is_equal_approx(position.y, altura_parada):
		_restaurar_visual(_cor_da_etapa())
		_estado = Estado.ATACANDO
		_tempo_ate_o_ataque = 1.0
		_tempo_ate_o_tiro_secundario = intervalo_tiro_mirado
		_rajadas_feitas = 0


func _cor_da_etapa() -> Color:
	return COR_POR_ETAPA.get(etapa_atual, COR_POR_ETAPA[3])


func cor_da_barra_de_vida() -> Color:
	return _cor_da_etapa()
