extends Node

const CENA_MENU_VOLUME := preload("res://scenes/menu_volume.tscn")

var habilitada: bool = true
var _menu_volume: MenuVolume

@onready var _texto: Label = $Texto


func _ready() -> void:
	# Este nó continua funcionando com o jogo pausado; o resto congela
	process_mode = Node.PROCESS_MODE_ALWAYS
	_texto.visible = false
	_texto.position = Vector2(0.0, 270.0)
	_texto.size = Vector2(480.0, 180.0)
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.add_theme_font_size_override("font_size", 26)
	_texto.text = "PAUSADO\n\nP ou Esc: continuar\nV: ajustar volume\nM: voltar ao menu"

	_menu_volume = CENA_MENU_VOLUME.instantiate()
	_menu_volume.visible = false
	_menu_volume.fechado.connect(_ao_fechar_menu_volume)
	add_child(_menu_volume)


func _input(event: InputEvent) -> void:
	var tecla := event as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	if not habilitada:
		return

	# Se o menu de volume estiver aberto, deixa ele consumir os inputs
	if _menu_volume != null and _menu_volume.visible:
		return

	if event.is_action_pressed("Pausa"):  # P ou Esc, definidos no mapa de teclas
		_alternar()
		get_viewport().set_input_as_handled()
	elif get_tree().paused:
		if tecla.keycode == KEY_V:
			_texto.visible = false
			_menu_volume.abrir()
			get_viewport().set_input_as_handled()
		elif tecla.keycode == KEY_M:
			get_tree().paused = false
			GerenciadorAudio.definir_jogo_pausado(false)
			get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _alternar() -> void:
	if _menu_volume != null and _menu_volume.visible:
		_menu_volume.fechar()
		return
	get_tree().paused = not get_tree().paused
	_texto.visible = get_tree().paused
	GerenciadorAudio.definir_jogo_pausado(get_tree().paused)


func _ao_fechar_menu_volume() -> void:
	if get_tree().paused:
		_texto.visible = true
