class_name GerenciadorFase
extends Node

signal spawn_solicitado(dados: DadosInimigo, posicao: Vector2)
signal tempo_esgotado

var _fase: DadosFase
var _tempo: float = 0.0
var _proximo: float = 0.0
var _ativo: bool = false


func iniciar(fase: DadosFase) -> void:
	_fase = fase
	_tempo = 0.0
	_proximo = 1.0  # primeiro inimigo depois de 1 segundo
	_ativo = true


func parar() -> void:
	_ativo = false


func _process(delta: float) -> void:
	if not _ativo or _fase.tipos.is_empty():
		return

	_tempo += delta
	if _tempo >= _fase.duracao:
		_ativo = false
		tempo_esgotado.emit()
		return

	_proximo -= delta
	if _proximo <= 0.0:
		# O ritmo acelera ao longo da fase
		var progresso := _tempo / _fase.duracao
		_proximo = lerpf(_fase.intervalo_inicial, _fase.intervalo_final, progresso)
		var posicao := Vector2(randf_range(30.0, 450.0), -30.0)
		spawn_solicitado.emit(_fase.tipos.pick_random(), posicao)
