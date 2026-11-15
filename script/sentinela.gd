extends ChefeBase

## Sentinela-01 (Fase 1): patrulha na horizontal e atira em leque. Um único padrão.

const COR_BASE := Color("#ff5d73")
const COR_AVISO := Color("#ffffff")

@export var velocidade: float = 120.0
@export var intervalo_ataque: float = 2.0
@export var tempo_aviso: float = 0.6

var _tempo_ate_o_ataque: float = 0.0
var _aviso_ja_emitido: bool = false


func _ready() -> void:
	nome = "Sentinela-01"
	vida_maxima = 50
	pontos = 300
	super()
	$Desenho.polygon = PackedVector2Array([
		Vector2(-44, 0), Vector2(-26, -24), Vector2(26, -24), Vector2(44, 0),
		Vector2(26, 24), Vector2(0, 34), Vector2(-26, 24)])
	$Desenho.color = COR_BASE
	_tempo_ate_o_ataque = intervalo_ataque


func _atualizar(delta: float) -> void:
	_patrulhar_horizontalmente(delta, velocidade)

	# Aviso visual e ataque em leque
	_tempo_ate_o_ataque -= delta
	if _tempo_ate_o_ataque <= tempo_aviso:
		if not _aviso_ja_emitido:
			_aviso_ja_emitido = true
			aviso_iniciado.emit()
		_piscar_aviso(_tempo_ate_o_ataque, COR_BASE, COR_AVISO)
	if _tempo_ate_o_ataque <= 0.0:
		_tempo_ate_o_ataque = intervalo_ataque
		_aviso_ja_emitido = false
		_restaurar_visual(COR_BASE)
		_atirar_leque(5, 0.6, 36.0)
