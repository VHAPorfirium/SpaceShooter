class_name MenuVolume
extends Control

signal fechado

const FONTE_TITULO := preload("res://assets/fontes/Orbitron.ttf")
const FONTE_TEXTO := preload("res://assets/fontes/ChakraPetch-SemiBold.ttf")
const COR_CONTORNO := Color("#0a0818")

@onready var _slider_master: HSlider = $Painel/VBox/LinhaMaster/SliderMaster
@onready var _label_master: Label = $Painel/VBox/LinhaMaster/ValorMaster
@onready var _slider_musica: HSlider = $Painel/VBox/LinhaMusica/SliderMusica
@onready var _label_musica: Label = $Painel/VBox/LinhaMusica/ValorMusica
@onready var _slider_efeitos: HSlider = $Painel/VBox/LinhaEfeitos/SliderEfeitos
@onready var _label_efeitos: Label = $Painel/VBox/LinhaEfeitos/ValorEfeitos
@onready var _botao_voltar: Button = $Painel/VBox/BotaoVoltar


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 200

	_atualizar_valores_dos_sliders()

	_slider_master.value_changed.connect(_ao_mudar_master)
	_slider_musica.value_changed.connect(_ao_mudar_musica)
	_slider_efeitos.value_changed.connect(_ao_mudar_efeitos)
	_botao_voltar.pressed.connect(fechar)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V):
		fechar()
		get_viewport().set_input_as_handled()


func abrir() -> void:
	_atualizar_valores_dos_sliders()
	visible = true
	_slider_master.grab_focus()


func fechar() -> void:
	GerenciadorAudio.salvar_configuracoes()
	visible = false
	fechado.emit()


func _atualizar_valores_dos_sliders() -> void:
	var master_val := GerenciadorAudio.obter_volume(GerenciadorAudio.NOME_BARRAMENTO_MASTER)
	var musica_val := GerenciadorAudio.obter_volume(GerenciadorAudio.NOME_BARRAMENTO_MUSICA)
	var efeitos_val := GerenciadorAudio.obter_volume(GerenciadorAudio.NOME_BARRAMENTO_EFEITOS)

	_slider_master.value = master_val * 100.0
	_slider_musica.value = musica_val * 100.0
	_slider_efeitos.value = efeitos_val * 100.0

	_label_master.text = "%d%%" % int(_slider_master.value)
	_label_musica.text = "%d%%" % int(_slider_musica.value)
	_label_efeitos.text = "%d%%" % int(_slider_efeitos.value)


func _ao_mudar_master(valor: float) -> void:
	GerenciadorAudio.definir_volume(GerenciadorAudio.NOME_BARRAMENTO_MASTER, valor / 100.0)
	_label_master.text = "%d%%" % int(valor)


func _ao_mudar_musica(valor: float) -> void:
	GerenciadorAudio.definir_volume(GerenciadorAudio.NOME_BARRAMENTO_MUSICA, valor / 100.0)
	_label_musica.text = "%d%%" % int(valor)


func _ao_mudar_efeitos(valor: float) -> void:
	GerenciadorAudio.definir_volume(GerenciadorAudio.NOME_BARRAMENTO_EFEITOS, valor / 100.0)
	_label_efeitos.text = "%d%%" % int(valor)
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.CONFIRMAR)
