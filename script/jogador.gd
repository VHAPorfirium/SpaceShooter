extends Area2D

signal disparou(posicao: Vector2, direcao: Vector2)
signal vidas_mudaram(vidas: int)
signal poderes_mudaram(texto: String)
signal destruida

enum ModoTiro { SIMPLES, DUPLO, TRIPLO }

const MAX_AJUDANTES := 2
const SLOTS_AJUDANTES := [Vector2(-36, 8), Vector2(36, 8)]

@export var velocidade: float = 340.0
@export var vidas_iniciais: int = 3
@export var cena_ajudante: PackedScene

var vidas: int
var _modo_tiro: ModoTiro = ModoTiro.SIMPLES
var _tempo_modo: float = 0.0
var _tempo_escudo: float = 0.0
var _ultimo_texto: String = ""
var _ajudantes: Array[Node2D] = []

@onready var _ponta: Marker2D = $Ponta
@onready var _recarga: Timer = $Recarga
@onready var _invencivel: Timer = $Invencivel


func _ready() -> void:
	vidas = vidas_iniciais
	$Desenho.polygon = PackedVector2Array([
		Vector2(0, -18), Vector2(15, 16), Vector2(5, 10),
		Vector2(-5, 10), Vector2(-15, 16)])
	$Desenho.color = Color("#5ee7ff")
	area_entered.connect(_ao_receber_area)


func _process(delta: float) -> void:
	var direcao := Input.get_vector("esquerda", "direita", "cima", "baixo")
	position += direcao * velocidade * delta
	position.x = clampf(position.x, 15.0, 465.0)
	position.y = clampf(position.y, 324.0, 693.0)

	if Input.is_action_pressed("atirar") and _recarga.is_stopped():
		_atirar()

	_atualizar_poderes(delta)

	# Pisca enquanto está invencível
	$Desenho.visible = _invencivel.is_stopped() or int(_invencivel.time_left * 12.0) % 2 == 0


func _draw() -> void:
	if _tempo_escudo > 0.0:
		draw_arc(Vector2.ZERO, 26.0, 0.0, TAU, 32, Color("#5ee7ff"), 2.0)


func _atirar() -> void:
	_recarga.start()
	match _modo_tiro:
		ModoTiro.SIMPLES:
			_emitir_tiro(0.0, 0.0)
		ModoTiro.DUPLO:
			_emitir_tiro(-8.0, 0.0)
			_emitir_tiro(8.0, 0.0)
		ModoTiro.TRIPLO:
			_emitir_tiro(-14.0, -0.2)
			_emitir_tiro(0.0, 0.0)
			_emitir_tiro(14.0, 0.2)

	# Cada nave de ajuda atira em linha reta
	for ajudante in _ajudantes:
		disparou.emit(ajudante.global_position + Vector2(0.0, -14.0), Vector2.UP)


func _emitir_tiro(deslocamento_x: float, angulo: float) -> void:
	var origem := _ponta.global_position + Vector2(deslocamento_x, 0.0)
	disparou.emit(origem, Vector2.UP.rotated(angulo))


func aplicar_poder(poder: DadosPoder) -> void:
	match poder.tipo:
		DadosPoder.Tipo.TIRO_DUPLO:
			_modo_tiro = ModoTiro.DUPLO
			_tempo_modo = poder.duracao
		DadosPoder.Tipo.TIRO_TRIPLO:
			_modo_tiro = ModoTiro.TRIPLO
			_tempo_modo = poder.duracao
		DadosPoder.Tipo.ESCUDO:
			_tempo_escudo = poder.duracao
			queue_redraw()
		DadosPoder.Tipo.AJUDANTE:
			_adicionar_ajudante()


func _adicionar_ajudante() -> void:
	if cena_ajudante == null or _ajudantes.size() >= MAX_AJUDANTES:
		return
	var ajudante: Node2D = cena_ajudante.instantiate()
	ajudante.position = SLOTS_AJUDANTES[_ajudantes.size()]
	add_child(ajudante)
	_ajudantes.append(ajudante)


func _remover_ajudantes() -> void:
	for ajudante in _ajudantes:
		ajudante.queue_free()
	_ajudantes.clear()


func _atualizar_poderes(delta: float) -> void:
	if _tempo_modo > 0.0:
		_tempo_modo -= delta
		if _tempo_modo <= 0.0:
			_modo_tiro = ModoTiro.SIMPLES
	if _tempo_escudo > 0.0:
		_tempo_escudo -= delta
		if _tempo_escudo <= 0.0:
			queue_redraw()

	var texto := _texto_poderes()
	if texto != _ultimo_texto:
		_ultimo_texto = texto
		poderes_mudaram.emit(texto)


func _texto_poderes() -> String:
	var partes: Array[String] = []
	if _modo_tiro == ModoTiro.DUPLO:
		partes.append("Tiro duplo %ds" % ceili(_tempo_modo))
	elif _modo_tiro == ModoTiro.TRIPLO:
		partes.append("Tiro triplo %ds" % ceili(_tempo_modo))
	if _tempo_escudo > 0.0:
		partes.append("Escudo %ds" % ceili(_tempo_escudo))
	if not _ajudantes.is_empty():
		partes.append("Ajudantes %d/%d" % [_ajudantes.size(), MAX_AJUDANTES])
	return " | ".join(partes)


func _ao_receber_area(area: Area2D) -> void:
	var item := area as ItemPoder
	if item != null:
		aplicar_poder(item.dados)
		item.queue_free()
		return

	if _tempo_escudo > 0.0:
		area.queue_free()  # o escudo destrói o que encosta
		return

	if not _invencivel.is_stopped():
		return

	area.queue_free()  # o inimigo some ao bater na nave
	vidas -= 1
	vidas_mudaram.emit(vidas)

	# Levar dano zera os poderes
	_modo_tiro = ModoTiro.SIMPLES
	_tempo_modo = 0.0
	_tempo_escudo = 0.0
	_remover_ajudantes()
	queue_redraw()

	if vidas <= 0:
		destruida.emit()
		queue_free()
	else:
		_invencivel.start()
