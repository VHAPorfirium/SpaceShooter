extends ChefeBase

## Ceifador (Fase 2): alterna rajadas miradas e investidas, sempre avisadas antes.

enum Estado { RAJADA, AVISO, INVESTIDA, RETORNO }

const COR_BASE := Color("#e056fd")
const COR_AVISO := Color("#ffffff")
const DESVIOS_DA_RAJADA: Array[float] = [-0.25, 0.0, 0.25]

@export var velocidade_lateral: float = 90.0
@export var rajadas_por_ciclo: int = 3
@export var intervalo_rajada: float = 1.0
@export var tempo_aviso: float = 0.9
@export var velocidade_investida: float = 520.0
@export var velocidade_retorno: float = 140.0
@export var altura_investida: float = 600.0

var _estado: Estado = Estado.RAJADA
var _rajadas_feitas: int = 0
var _tempo: float = 1.2
var _alvo_x: float = 240.0


func _ready() -> void:
	nome = "Ceifador"
	vida_maxima = 70
	pontos = 500
	super()
	$Desenho.polygon = PackedVector2Array([
		Vector2(-50, -10), Vector2(-30, -26), Vector2(0, -18), Vector2(30, -26),
		Vector2(50, -10), Vector2(28, 20), Vector2(0, 34), Vector2(-28, 20)])
	$Desenho.color = COR_BASE


func _atualizar(delta: float) -> void:
	match _estado:
		Estado.RAJADA:
			_patrulhar_horizontalmente(delta, velocidade_lateral)
			_tempo -= delta
			if _tempo <= 0.0:
				_atirar_rajada_mirada(DESVIOS_DA_RAJADA, 30.0)
				_rajadas_feitas += 1
				_tempo = intervalo_rajada
				if _rajadas_feitas >= rajadas_por_ciclo:
					_rajadas_feitas = 0
					_iniciar_aviso()
		Estado.AVISO:
			_tempo -= delta
			position.x = move_toward(position.x, _alvo_x, 220.0 * delta)
			_piscar_aviso(_tempo, COR_BASE, COR_AVISO)
			if _tempo <= 0.0:
				_restaurar_visual(COR_BASE)
				_estado = Estado.INVESTIDA
		Estado.INVESTIDA:
			position.y += velocidade_investida * delta
			if position.y >= altura_investida:
				position.y = altura_investida
				_estado = Estado.RETORNO
		Estado.RETORNO:
			position.y = move_toward(position.y, altura_parada, velocidade_retorno * delta)
			if is_equal_approx(position.y, altura_parada):
				_estado = Estado.RAJADA
				_tempo = 1.0


func _iniciar_aviso() -> void:
	_estado = Estado.AVISO
	_tempo = tempo_aviso
	aviso_iniciado.emit()
	_alvo_x = _posicao_x_do_jogador_dentro_da_patrulha()
