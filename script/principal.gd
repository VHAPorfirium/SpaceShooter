extends Node2D

enum Estado { JOGANDO, TRANSICAO, FIM, VITORIA }

@export var cena_tiro: PackedScene
@export var cena_tiro_inimigo: PackedScene
@export var cena_inimigo: PackedScene
@export var cena_item: PackedScene
@export var poderes: Array[DadosPoder]
@export var chance_drop: float = 0.12

var _fases: Array[DadosFase] = []
var _fase_atual: int = 0
var _estado: Estado = Estado.JOGANDO
var _ondas_acabaram: bool = false
var _chefe_ativo: bool = false
var _pontos: int = 0
var _recorde: int = 0

@onready var _jogador: Area2D = $Jogador
@onready var _tiros: Node2D = $Tiros
@onready var _tiros_inimigos: Node2D = $TirosInimigos
@onready var _inimigos: Node2D = $Inimigos
@onready var _itens: Node2D = $Itens
@onready var _gerenciador: GerenciadorFase = $Fase
@onready var _tempo_transicao: Timer = $TempoTransicao
@onready var _placar: Label = $Placar
@onready var _recorde_label: Label = $RecordeLabel
@onready var _vidas_label: Label = $Vidas
@onready var _poder_label: Label = $PoderLabel
@onready var _fase_label: Label = $FaseLabel
@onready var _mensagem: Label = $Mensagem
@onready var _barra_chefe: ProgressBar = $BarraChefe


func _ready() -> void:
	_jogador.disparou.connect(_ao_jogador_disparar)
	_jogador.vidas_mudaram.connect(_ao_vidas_mudarem)
	_jogador.poderes_mudaram.connect(_ao_poderes_mudarem)
	_jogador.destruida.connect(_ao_jogador_destruido)
	_gerenciador.spawn_solicitado.connect(_ao_spawn_solicitado)
	_gerenciador.tempo_esgotado.connect(_ao_ondas_esgotadas)
	_tempo_transicao.timeout.connect(_ao_fim_transicao)

	_mensagem.visible = false
	_mensagem.position = Vector2(0, 250)
	_mensagem.size = Vector2(480, 220)
	_mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mensagem.add_theme_font_size_override("font_size", 28)

	_fase_label.position = Vector2(0, 10)
	_fase_label.size = Vector2(480, 24)
	_fase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_barra_chefe.position = Vector2(90, 40)
	_barra_chefe.size = Vector2(300, 12)
	_barra_chefe.show_percentage = false
	_barra_chefe.visible = false

	_recorde = Recorde.carregar()
	_recorde_label.text = "Recorde %d" % _recorde
	_poder_label.text = ""
	_ao_vidas_mudarem(_jogador.vidas)

	_fases.append(CatalogoFases.fase_1())
	_fases.append(CatalogoFases.fase_2())
	_iniciar_fase(0)


func _process(_delta: float) -> void:
	if _estado != Estado.JOGANDO or not _ondas_acabaram or _chefe_ativo:
		return
	if _inimigos.get_child_count() > 0:
		return
	var fase := _fases[_fase_atual]
	if fase.chefe != null:
		_iniciar_chefe(fase)
	else:
		_concluir_fase()


func _unhandled_input(event: InputEvent) -> void:
	var terminou := _estado == Estado.FIM or _estado == Estado.VITORIA
	if not terminou:
		return
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	else:
		var tecla := event as InputEventKey
		if tecla != null and tecla.pressed and not tecla.echo and tecla.keycode == KEY_M:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _iniciar_fase(indice: int) -> void:
	_fase_atual = indice
	_ondas_acabaram = false
	_chefe_ativo = false
	_estado = Estado.JOGANDO
	var fase := _fases[indice]
	RenderingServer.set_default_clear_color(fase.cor_fundo)
	_fase_label.text = fase.nome
	_barra_chefe.visible = false
	_mensagem.visible = false
	_gerenciador.iniciar(fase)


func _iniciar_chefe(fase: DadosFase) -> void:
	_chefe_ativo = true
	var chefe: ChefeBase = fase.chefe.instantiate()
	chefe.position = Vector2(240.0, -70.0)
	chefe.vida_mudou.connect(_ao_vida_chefe_mudou)
	chefe.derrotado.connect(_ao_chefe_derrotado)
	chefe.disparou.connect(_ao_chefe_disparar)
	_inimigos.add_child(chefe)
	_fase_label.text = "Chefe: %s" % chefe.nome


func _concluir_fase() -> void:
	for tiro in _tiros_inimigos.get_children():
		tiro.queue_free()
	if _fase_atual + 1 < _fases.size():
		_estado = Estado.TRANSICAO
		_mensagem.text = "%s\nconcluída!" % _fases[_fase_atual].nome
		_mensagem.visible = true
		_tempo_transicao.start()
	else:
		_estado = Estado.VITORIA
		_finalizar_partida("VITÓRIA!")


func _ao_fim_transicao() -> void:
	if _estado == Estado.TRANSICAO:
		_iniciar_fase(_fase_atual + 1)


func _ao_ondas_esgotadas() -> void:
	_ondas_acabaram = true


func _ao_spawn_solicitado(dados: DadosInimigo, posicao: Vector2) -> void:
	var inimigo: Inimigo = cena_inimigo.instantiate()
	inimigo.dados = dados
	inimigo.position = posicao
	inimigo.morreu.connect(_ao_inimigo_morrer)
	inimigo.disparou.connect(_ao_inimigo_disparar)
	_inimigos.add_child(inimigo)


func _ao_jogador_disparar(posicao: Vector2, direcao: Vector2) -> void:
	var tiro: Tiro = cena_tiro.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros.add_child(tiro)


func _ao_inimigo_disparar(posicao: Vector2) -> void:
	var tiro: TiroInimigo = cena_tiro_inimigo.instantiate()
	tiro.position = posicao
	_tiros_inimigos.add_child(tiro)


func _ao_chefe_disparar(posicao: Vector2, direcao: Vector2) -> void:
	var tiro: TiroInimigo = cena_tiro_inimigo.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros_inimigos.add_child(tiro)


func _ao_vida_chefe_mudou(vida: int, vida_maxima: int) -> void:
	_barra_chefe.max_value = vida_maxima
	_barra_chefe.value = vida
	_barra_chefe.visible = true


func _ao_chefe_derrotado(pontos: int, _posicao: Vector2) -> void:
	_pontos += pontos
	_placar.text = "Pontos %d" % _pontos
	_chefe_ativo = false
	_barra_chefe.visible = false
	_concluir_fase()


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
	_tempo_transicao.stop()
	_finalizar_partida("FIM DE JOGO")


func _finalizar_partida(titulo: String) -> void:
	$Pausa.habilitada = false
	_gerenciador.parar()
	_barra_chefe.visible = false

	var novo_recorde := _pontos > _recorde
	if novo_recorde:
		_recorde = _pontos
		Recorde.salvar(_recorde)
		_recorde_label.text = "Recorde %d" % _recorde

	var texto := "%s\nPontos %d\nRecorde %d" % [titulo, _pontos, _recorde]
	if novo_recorde:
		texto += "\nNOVO RECORDE!"
	texto += "\nEnter: jogar de novo\nM: menu"
	_mensagem.text = texto
	_mensagem.visible = true
