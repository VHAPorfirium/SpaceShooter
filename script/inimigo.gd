class_name Inimigo
extends Area2D

signal morreu(pontos: int, posicao: Vector2)
signal disparou(posicao: Vector2)

const FORMAS := {
	DadosInimigo.Forma.TRIANGULO: [
		Vector2(0, 16), Vector2(15, -12), Vector2(-15, -12)],
	DadosInimigo.Forma.SETA: [
		Vector2(0, 14), Vector2(15, -12), Vector2(0, -4), Vector2(-15, -12)],
	DadosInimigo.Forma.BLOCO: [
		Vector2(-19, -14), Vector2(19, -14), Vector2(19, 12),
		Vector2(8, 12), Vector2(0, 22), Vector2(-8, 12), Vector2(-19, 12)],
	DadosInimigo.Forma.ROCHA: [
		Vector2(-6, -22), Vector2(12, -19), Vector2(22, -6), Vector2(19, 10),
		Vector2(8, 21), Vector2(-10, 20), Vector2(-21, 8), Vector2(-20, -10)],
}

const TAMANHO_BASE_DO_DESENHO_DA_ROCHA := Vector2(40, 40)

@export var dados: DadosInimigo

var _vida: int
var _tempo: float = 0.0
var _tempo_tiro: float = 0.0
var _x_inicial: float


func _ready() -> void:
	if dados == null:
		push_error("Inimigo criado sem dados.")
		set_process(false)
		queue_free()
		return
	_vida = dados.vida
	_tempo_tiro = dados.intervalo_tiro
	_x_inicial = position.x
	$Desenho.polygon = PackedVector2Array(FORMAS[dados.forma])
	$Desenho.color = dados.cor
	if dados.forma == DadosInimigo.Forma.ROCHA:
		$Desenho.scale = dados.tamanho / TAMANHO_BASE_DO_DESENHO_DA_ROCHA  # plano B acompanha o tamanho
	$Imagem.exibir(dados.textura, dados.tamanho, [$Desenho])
	var forma_colisao := RectangleShape2D.new()
	forma_colisao.size = dados.tamanho
	$Forma.shape = forma_colisao
	$Notificador.screen_exited.connect(queue_free)
	area_entered.connect(_ao_receber_area)


func _process(delta: float) -> void:
	_tempo += delta
	position.y += dados.velocidade * delta
	if dados.movimento == DadosInimigo.Movimento.ZIGZAG:
		position.x = _x_inicial + sin(_tempo * dados.frequencia) * dados.amplitude
	if dados.velocidade_giro != 0.0:
		$Desenho.rotation += dados.velocidade_giro * delta
		$Imagem.rotation += dados.velocidade_giro * delta

	if dados.atira:
		_tempo_tiro -= delta
		if _tempo_tiro <= 0.0:
			_tempo_tiro = dados.intervalo_tiro
			disparou.emit(global_position + Vector2(0, 20))


func _ao_receber_area(area: Area2D) -> void:
	area.queue_free()  # o tiro some ao acertar
	if _vida <= 0:
		return  # evita pontuar duas vezes se dois tiros chegarem juntos
	_vida -= 1
	if _vida > 0 and dados.textura_dano != null:
		$Imagem.trocar_textura(dados.textura_dano)  # mostra que já levou tiro
	if _vida <= 0:
		morreu.emit(dados.pontos, global_position)
		queue_free()
