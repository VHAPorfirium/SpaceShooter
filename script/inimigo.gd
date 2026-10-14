class_name Inimigo
extends Area2D

signal morreu(pontos: int)

const FORMAS := {
	DadosInimigo.Forma.TRIANGULO: [
		Vector2(0, 16), Vector2(15, -12), Vector2(-15, -12)],
	DadosInimigo.Forma.SETA: [
		Vector2(0, 14), Vector2(15, -12), Vector2(0, -4), Vector2(-15, -12)],
	DadosInimigo.Forma.BLOCO: [
		Vector2(-19, -14), Vector2(19, -14), Vector2(19, 12),
		Vector2(8, 12), Vector2(0, 22), Vector2(-8, 12), Vector2(-19, 12)],
}

@export var dados: DadosInimigo

var _vida: int
var _tempo: float = 0.0
var _x_inicial: float


func _ready() -> void:
	if dados == null:
		push_error("Inimigo criado sem dados.")
		set_process(false)
		queue_free()
		return
	_vida = dados.vida
	_x_inicial = position.x
	$Desenho.polygon = PackedVector2Array(FORMAS[dados.forma])
	$Desenho.color = dados.cor
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


func _ao_receber_area(area: Area2D) -> void:
	area.queue_free()  # o tiro some ao acertar
	if _vida <= 0:
		return  # evita pontuar duas vezes se dois tiros chegarem juntos
	_vida -= 1
	if _vida <= 0:
		morreu.emit(dados.pontos)
		queue_free()
