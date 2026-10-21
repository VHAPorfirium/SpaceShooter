extends Control

const COR_FUNDO := Color("#14102b")

@onready var _titulo_1: Label = $Titulo1
@onready var _titulo_2: Label = $Titulo2
@onready var _instrucoes: Label = $Instrucoes
@onready var _recorde: Label = $Recorde
@onready var _iniciar: Label = $Iniciar


func _ready() -> void:
	RenderingServer.set_default_clear_color(COR_FUNDO)
	_configurar(_titulo_1, "SPACE", 170.0, 64, Color("#5ee7ff"))
	_configurar(_titulo_2, "SHOOTER", 245.0, 64, Color("#ff5d73"))
	_configurar(_instrucoes, "Setas ou WASD: mover\nEspaço: atirar\nP ou Esc: pausar", 390.0, 20, Color("#f4f1ff"))
	_configurar(_recorde, "Recorde %d" % Recorde.carregar(), 520.0, 18, Color("#a89fd6"))
	_configurar(_iniciar, "Pressione Enter para jogar\nEsc para sair", 580.0, 24, Color("#ffd166"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/principal.tscn")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _configurar(rotulo: Label, texto: String, y: float, tamanho: int, cor: Color) -> void:
	rotulo.text = texto
	rotulo.position = Vector2(0.0, y)
	rotulo.size = Vector2(480.0, 100.0)
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.add_theme_color_override("font_color", cor)
