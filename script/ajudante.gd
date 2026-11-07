extends Node2D


func _ready() -> void:
	$Desenho.polygon = PackedVector2Array([
		Vector2(0, -11), Vector2(9, 10), Vector2(3, 6),
		Vector2(-3, 6), Vector2(-9, 10)])
	$Desenho.color = Color("#ff8fd1")
