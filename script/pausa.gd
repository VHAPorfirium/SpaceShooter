extends Node

var habilitada: bool = true

@onready var _texto: Label = $Texto


func _ready() -> void:
	# Este nó continua funcionando com o jogo pausado; o resto congela
	process_mode = Node.PROCESS_MODE_ALWAYS
	_texto.visible = false
	_texto.position = Vector2(0.0, 290.0)
	_texto.size = Vector2(480.0, 140.0)
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.add_theme_font_size_override("font_size", 28)
	_texto.text = "PAUSADO\nP ou Esc: continuar\nM: voltar ao menu"


func _input(event: InputEvent) -> void:
	var tecla := event as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	if not habilitada:
		return
	if tecla.keycode == KEY_P or tecla.keycode == KEY_ESCAPE:
		_alternar()
		get_viewport().set_input_as_handled()
	elif get_tree().paused and tecla.keycode == KEY_M:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _alternar() -> void:
	get_tree().paused = not get_tree().paused
	_texto.visible = get_tree().paused
