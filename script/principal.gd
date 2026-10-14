extends Node2D

enum Estado { JOGANDO, FIM }

@export var cena_tiro: PackedScene
@export var cena_tiro_inimigo: PackedScene
@export var cena_inimigo: PackedScene
@export var cena_item: PackedScene
@export var tipos_inimigo: Array[DadosInimigo]
@export var poderes: Array[DadosPoder]
@export var chance_drop: float = 0.12

var _estado: Estado = Estado.JOGANDO
var _pontos: int = 0
var _recorde: int = 0

@onready var _jogador: Area2D = $Jogador
@onready var _tiros: Node2D = $Tiros
@onready var _tiros_inimigos: Node2D = $TirosInimigos
@onready var _inimigos: Node2D = $Inimigos
@onready var _itens: Node2D = $Itens
@onready var _placar: Label = $Placar
@onready var _recorde_label: Label = $RecordeLabel
@onready var _vidas_label: Label = $Vidas
@onready var _poder_label: Label = $PoderLabel
@onready var _mensagem: Label = $Mensagem


func _ready() -> void:
	_jogador.disparou.connect(_ao_jogador_disparar)
	_jogador.vidas_mudaram.connect(_ao_vidas_mudarem)
	_jogador.poderes_mudaram.connect(_ao_poderes_mudarem)
	_jogador.destruida.connect(_ao_jogador_destruido)
	$TempoSpawn.timeout.connect(_ao_tempo_spawn)

	_mensagem.visible = false
	_mensagem.position = Vector2(0, 250)
	_mensagem.size = Vector2(480, 220)
	_mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mensagem.add_theme_font_size_override("font_size", 28)

	_recorde = Recorde.carregar()
	_recorde_label.text = "Recorde %d" % _recorde
	_poder_label.text = ""
	_ao_vidas_mudarem(_jogador.vidas)


func _unhandled_input(event: InputEvent) -> void:
	if _estado == Estado.FIM and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _ao_jogador_disparar(posicao: Vector2, direcao: Vector2) -> void:
	var tiro: Tiro = cena_tiro.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros.add_child(tiro)


func _ao_inimigo_disparar(posicao: Vector2) -> void:
	var tiro: Area2D = cena_tiro_inimigo.instantiate()
	tiro.position = posicao
	_tiros_inimigos.add_child(tiro)


func _ao_tempo_spawn() -> void:
	if tipos_inimigo.is_empty():
		return
	var inimigo: Inimigo = cena_inimigo.instantiate()
	inimigo.dados = tipos_inimigo.pick_random()
	inimigo.position = Vector2(randf_range(30.0, 450.0), -30.0)
	inimigo.morreu.connect(_ao_inimigo_morrer)
	inimigo.disparou.connect(_ao_inimigo_disparar)
	_inimigos.add_child(inimigo)


func _ao_inimigo_morrer(pontos: int, posicao: Vector2) -> void:
	_pontos += pontos
	_placar.text = "Pontos %d" % _pontos
	# Adiado: criar uma Area2D no meio de um callback de física causa erro
	_tentar_dropar.call_deferred(posicao)


func _tentar_dropar(posicao: Vector2) -> void:
	if poderes.is_empty() or cena_item == null:
		return
	if randf() > chance_drop:
		return
	var item: ItemPoder = cena_item.instantiate()
	item.dados = poderes.pick_random()
	item.position = posicao
	_itens.add_child(item)


func _ao_vidas_mudarem(vidas: int) -> void:
	_vidas_label.text = "Vidas %d" % vidas


func _ao_poderes_mudarem(texto: String) -> void:
	_poder_label.text = texto


func _ao_jogador_destruido() -> void:
	_estado = Estado.FIM
	$TempoSpawn.stop()

	var novo_recorde := _pontos > _recorde
	if novo_recorde:
		_recorde = _pontos
		Recorde.salvar(_recorde)
		_recorde_label.text = "Recorde %d" % _recorde

	var texto := "FIM DE JOGO\nPontos %d\nRecorde %d" % [_pontos, _recorde]
	if novo_recorde:
		texto += "\nNOVO RECORDE!"
	texto += "\nEnter para jogar de novo"
	_mensagem.text = texto
	_mensagem.visible = true
