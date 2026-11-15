extends Control

## Tela inicial: fundo e logo da arte (ou o título em texto, no plano B), instruções e recorde.

const COR_FUNDO := Color("#14102b")
const MUSICA_MENU := preload("res://assets/audio/musicas/menu.wav")
const FONTE_DAS_INSTRUCOES := preload("res://assets/fontes/ChakraPetch-SemiBold.ttf")
const COR_DO_CONTORNO := Color("#0a0818")
const AREA_DO_LOGO := Rect2(40, 70, 400, 180)

## Arte da tela inicial. Vazio = fundo de estrelas e título em texto.
@export var imagem_de_fundo: Texture2D
@export var logo: Texture2D

@onready var _fundo: TextureRect = $Fundo
@onready var _logo: TextureRect = $Logo
@onready var _titulo_1: Label = $Titulo1
@onready var _titulo_2: Label = $Titulo2
@onready var _instrucoes: Label = $Instrucoes
@onready var _recorde: Label = $Recorde
@onready var _iniciar: Label = $Iniciar


func _ready() -> void:
	RenderingServer.set_default_clear_color(COR_FUNDO)
	GerenciadorAudio.tocar_musica(MUSICA_MENU)
	_configurar_arte()
	_configurar(_titulo_1, "SPACE", 170.0, 64, Color("#5ee7ff"), null)
	_configurar(_titulo_2, "SHOOTER", 245.0, 64, Color("#ff5d73"), null)
	_configurar(_instrucoes, "Setas ou WASD: mover\nEspaço: atirar\nP ou Esc: pausar", 290.0, 20, Color("#f4f1ff"), FONTE_DAS_INSTRUCOES)
	_configurar(_recorde, "Recorde %d" % Recorde.carregar(), 392.0, 18, Color("#a89fd6"), null)
	_configurar(_iniciar, "Pressione Enter para jogar\nEsc para sair", 430.0, 22, Color("#ffd166"), FONTE_DAS_INSTRUCOES)
	var tem_logo := logo != null
	_titulo_1.visible = not tem_logo  # plano B: título em texto
	_titulo_2.visible = not tem_logo


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.CONFIRMAR)
		get_tree().change_scene_to_file("res://scenes/principal.tscn")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _configurar_arte() -> void:
	_fundo.texture = imagem_de_fundo
	_fundo.visible = imagem_de_fundo != null
	_fundo.position = Vector2.ZERO
	_fundo.size = Vector2(480, 720)
	_fundo.z_index = -110  # atrás das estrelas animadas
	_logo.texture = logo
	_logo.visible = logo != null
	_logo.position = AREA_DO_LOGO.position
	_logo.size = AREA_DO_LOGO.size


func _configurar(rotulo: Label, texto: String, y: float, tamanho: int, cor: Color, fonte: Font) -> void:
	rotulo.text = texto
	rotulo.position = Vector2(0.0, y)
	rotulo.size = Vector2(480.0, 100.0)
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.add_theme_color_override("font_color", cor)
	rotulo.add_theme_color_override("font_outline_color", COR_DO_CONTORNO)
	rotulo.add_theme_constant_override("outline_size", 5)
	if fonte != null:
		rotulo.add_theme_font_override("font", fonte)
