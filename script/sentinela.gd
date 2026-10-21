extends ChefeBase

const COR_BASE := Color("#ff5d73")
const COR_AVISO := Color("#ffffff")

@export var velocidade: float = 120.0
@export var intervalo_ataque: float = 2.0
@export var tempo_aviso: float = 0.6

var _direcao: float = 1.0
var _tempo_ataque: float = 0.0


func _ready() -> void:
	nome = "Sentinela-01"
	vida_maxima = 50
	pontos = 300
	super()
	$Desenho.polygon = PackedVector2Array([
		Vector2(-44, 0), Vector2(-26, -24), Vector2(26, -24), Vector2(44, 0),
		Vector2(26, 24), Vector2(0, 34), Vector2(-26, 24)])
	$Desenho.color = COR_BASE
	_tempo_ataque = intervalo_ataque


func _atualizar(delta: float) -> void:
	# Patrulha de um lado a outro
	position.x += _direcao * velocidade * delta
	if position.x > 420.0:
		position.x = 420.0
		_direcao = -1.0
	elif position.x < 60.0:
		position.x = 60.0
		_direcao = 1.0

	# Aviso visual e ataque em leque
	_tempo_ataque -= delta
	if _tempo_ataque <= tempo_aviso:
		$Desenho.color = COR_AVISO if int(_tempo_ataque * 14.0) % 2 == 0 else COR_BASE
	if _tempo_ataque <= 0.0:
		_tempo_ataque = intervalo_ataque
		$Desenho.color = COR_BASE
		_atirar_leque()


func _atirar_leque() -> void:
	for i in 5:
		var angulo := lerpf(-0.6, 0.6, i / 4.0)
		disparou.emit(global_position + Vector2(0.0, 36.0), Vector2.DOWN.rotated(angulo))
