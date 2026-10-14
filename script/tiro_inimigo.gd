extends Area2D

@export var velocidade: float = 230.0


func _ready() -> void:
	$Desenho.polygon = PackedVector2Array([
		Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)])
	$Desenho.color = Color("#ffffff")
	$Notificador.screen_exited.connect(queue_free)


func _process(delta: float) -> void:
	position.y += velocidade * delta
