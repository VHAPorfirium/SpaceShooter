extends Area2D

signal disparou(posicao: Vector2)
signal vidas_mudaram(vidas: int)
signal destruida

@export var velocidade: float = 340.0
@export var vidas_iniciais: int = 3

var vidas: int

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

	# Pisca enquanto está invencível
	$Desenho.visible = _invencivel.is_stopped() or int(_invencivel.time_left * 12.0) % 2 == 0


func _atirar() -> void:
	_recarga.start()
	disparou.emit(_ponta.global_position)


func _ao_receber_area(area: Area2D) -> void:
	if not _invencivel.is_stopped():
		return
	area.queue_free()  # o inimigo some ao bater na nave
	vidas -= 1
	vidas_mudaram.emit(vidas)
	if vidas <= 0:
		destruida.emit()
		queue_free()
	else:
		_invencivel.start()
