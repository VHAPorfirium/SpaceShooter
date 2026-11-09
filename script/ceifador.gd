extends ChefeBase

enum Estado { RAJADA, AVISO, INVESTIDA, RETORNO }

const COR_BASE := Color("#e056fd")
const COR_AVISO := Color("#ffffff")

@export var velocidade_lateral: float = 90.0
@export var rajadas_por_ciclo: int = 3
@export var intervalo_rajada: float = 1.0
@export var tempo_aviso: float = 0.9
@export var velocidade_investida: float = 520.0
@export var velocidade_retorno: float = 140.0
@export var altura_investida: float = 600.0

var _estado: Estado = Estado.RAJADA
var _direcao: float = 1.0
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
			_mover_lateral(delta)
			_tempo -= delta
			if _tempo <= 0.0:
				_atirar_rajada()
				_rajadas_feitas += 1
				_tempo = intervalo_rajada
				if _rajadas_feitas >= rajadas_por_ciclo:
					_rajadas_feitas = 0
					_iniciar_aviso()
		Estado.AVISO:
			_tempo -= delta
			position.x = move_toward(position.x, _alvo_x, 220.0 * delta)
			$Desenho.color = COR_AVISO if int(_tempo * 14.0) % 2 == 0 else COR_BASE
			if _tempo <= 0.0:
				$Desenho.color = COR_BASE
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


func _mover_lateral(delta: float) -> void:
	position.x += _direcao * velocidade_lateral * delta
	if position.x > 420.0:
		position.x = 420.0
		_direcao = -1.0
	elif position.x < 60.0:
		position.x = 60.0
		_direcao = 1.0


func _iniciar_aviso() -> void:
	_estado = Estado.AVISO
	_tempo = tempo_aviso
	_alvo_x = position.x
	var jogador := get_tree().get_first_node_in_group("jogador") as Node2D
	if jogador != null:
		_alvo_x = clampf(jogador.global_position.x, 60.0, 420.0)


func _atirar_rajada() -> void:
	var base := Vector2.DOWN
	var jogador := get_tree().get_first_node_in_group("jogador") as Node2D
	if jogador != null:
		base = (jogador.global_position - global_position).normalized()
	for desvio in [-0.25, 0.0, 0.25]:
		disparou.emit(global_position + Vector2(0.0, 30.0), base.rotated(desvio))
