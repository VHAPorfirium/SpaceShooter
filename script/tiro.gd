extends Area2D

@export var velocidade: float = 620.0


func _ready() -> void:
	$Desenho.polygon = PackedVector2Array([
		Vector2(-2.5, -7), Vector2(2.5, -7), Vector2(2.5, 7), Vector2(-2.5, 7)])
	$Desenho.color = Color("#ffd166")
	$Notificador.screen_exited.connect(queue_free)


func _process(delta: float) -> void:
	position.y -= velocidade * delta
