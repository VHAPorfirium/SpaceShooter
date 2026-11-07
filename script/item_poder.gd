class_name ItemPoder
extends Area2D

@export var dados: DadosPoder
@export var velocidade: float = 90.0


func _ready() -> void:
	if dados == null:
		queue_free()
		return

	var pontos := PackedVector2Array()
	for i in 20:
		var angulo := TAU * i / 20.0
		pontos.append(Vector2(cos(angulo), sin(angulo)) * 11.0)
	$Desenho.polygon = pontos
	$Desenho.color = dados.cor

	$Rotulo.text = dados.rotulo
	$Rotulo.position = Vector2(-12, -10)
	$Rotulo.size = Vector2(24, 20)
	$Rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	$Rotulo.add_theme_font_size_override("font_size", 11)
	$Rotulo.add_theme_color_override("font_color", Color("#14102b"))

	$Notificador.screen_exited.connect(queue_free)


func _process(delta: float) -> void:
	position.y += velocidade * delta
