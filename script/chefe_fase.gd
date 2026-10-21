class_name ChefeBase
extends Area2D

signal vida_mudou(vida: int, vida_maxima: int)
signal derrotado(pontos: int, posicao: Vector2)
signal disparou(posicao: Vector2, direcao: Vector2)

@export var nome: String = "Chefe"
@export var vida_maxima: int = 50
@export var pontos: int = 300
@export var altura_parada: float = 110.0

var vida: int
var entrando: bool = true


func _ready() -> void:
	add_to_group("chefe")
	vida = vida_maxima
	area_entered.connect(_ao_receber_area)
	vida_mudou.emit(vida, vida_maxima)


func _process(delta: float) -> void:
	if entrando:
		position.y = move_toward(position.y, altura_parada, 90.0 * delta)
		if is_equal_approx(position.y, altura_parada):
			entrando = false
		return
	_atualizar(delta)


func _atualizar(_delta: float) -> void:
	pass  # cada chefe define o seu comportamento


func _ao_receber_area(area: Area2D) -> void:
	area.queue_free()  # o tiro some ao acertar
	if entrando or vida <= 0:
		return  # invulnerável durante a entrada
	vida -= 1
	vida_mudou.emit(vida, vida_maxima)
	if vida <= 0:
		derrotado.emit(pontos, global_position)
		queue_free()
