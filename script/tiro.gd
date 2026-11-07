class_name Tiro
extends Area2D

@export var velocidade: float = 620.0

var direcao: Vector2 = Vector2.UP


func _ready() -> void:
	rotation = direcao.angle() + PI / 2.0
	$Desenho.polygon = PackedVector2Array([
		Vector2(-2.5, -7), Vector2(2.5, -7), Vector2(2.5, 7), Vector2(-2.5, 7)])
	$Desenho.color = Color("#ffd166")
	$Notificador.screen_exited.connect(queue_free)


func _process(delta: float) -> void:
	position += direcao * velocidade * delta
