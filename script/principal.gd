extends Node2D

enum Estado { JOGANDO, FIM }

@export var cena_tiro: PackedScene
@export var cena_inimigo: PackedScene
@export var tipos_inimigo: Array[DadosInimigo]

var _estado: Estado = Estado.JOGANDO
var _pontos: int = 0

@onready var _jogador: Area2D = $Jogador
@onready var _tiros: Node2D = $Tiros
@onready var _inimigos: Node2D = $Inimigos
@onready var _placar: Label = $Placar
@onready var _vidas_label: Label = $Vidas
@onready var _mensagem: Label = $Mensagem


func _ready() -> void:
	_jogador.disparou.connect(_ao_jogador_disparar)
	_jogador.vidas_mudaram.connect(_ao_vidas_mudarem)
	_jogador.destruida.connect(_ao_jogador_destruido)
	$TempoSpawn.timeout.connect(_ao_tempo_spawn)

	_mensagem.visible = false
	_mensagem.position = Vector2(0, 280)
	_mensagem.size = Vector2(480, 160)
	_mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mensagem.add_theme_font_size_override("font_size", 28)
	_ao_vidas_mudarem(_jogador.vidas)


func _unhandled_input(event: InputEvent) -> void:
	if _estado == Estado.FIM and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _ao_jogador_disparar(posicao: Vector2) -> void:
	var tiro: Area2D = cena_tiro.instantiate()
	tiro.position = posicao
	_tiros.add_child(tiro)


func _ao_tempo_spawn() -> void:
	if tipos_inimigo.is_empty():
		return
	var inimigo: Inimigo = cena_inimigo.instantiate()
	inimigo.dados = tipos_inimigo.pick_random()
	inimigo.position = Vector2(randf_range(30.0, 450.0), -30.0)
	inimigo.morreu.connect(_ao_inimigo_morrer)
	_inimigos.add_child(inimigo)


func _ao_inimigo_morrer(pontos: int) -> void:
	_pontos += pontos
	_placar.text = "Pontos %d" % _pontos


func _ao_vidas_mudarem(vidas: int) -> void:
	_vidas_label.text = "Vidas %d" % vidas


func _ao_jogador_destruido() -> void:
	_estado = Estado.FIM
	$TempoSpawn.stop()
	_mensagem.text = "FIM DE JOGO\nPontos %d\nEnter para jogar de novo" % _pontos
	_mensagem.visible = true
