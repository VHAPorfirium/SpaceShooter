class_name GerenciadorFase
extends Node

## Toca o roteiro de ondas da fase: quando chega o momento de cada onda,
## pede a criação dos inimigos nas posições da formação.
## As pausas de respiro são os intervalos sem onda no roteiro.

signal spawn_solicitado(dados: DadosInimigo, posicao: Vector2)
signal roteiro_concluido  # a última onda já entrou em cena

const MARGEM_LATERAL_MINIMA := 30.0

var _ondas_em_ordem: Array[DadosOnda] = []
var _indice_proxima_onda: int = 0
var _tempo_decorrido_segundos: float = 0.0
var _ativo: bool = false


func iniciar(fase: DadosFase) -> void:
	_ondas_em_ordem = fase.ondas.duplicate()
	_ondas_em_ordem.sort_custom(func(onda_a: DadosOnda, onda_b: DadosOnda) -> bool:
		return onda_a.momento_segundos < onda_b.momento_segundos)
	_indice_proxima_onda = 0
	_tempo_decorrido_segundos = 0.0
	_ativo = true


func parar() -> void:
	_ativo = false


func _process(delta: float) -> void:
	if not _ativo:
		return

	_tempo_decorrido_segundos += delta
	while _ha_onda_pronta_para_entrar():
		_lancar_onda(_ondas_em_ordem[_indice_proxima_onda])
		_indice_proxima_onda += 1

	if _indice_proxima_onda >= _ondas_em_ordem.size():
		_ativo = false
		roteiro_concluido.emit()


func _ha_onda_pronta_para_entrar() -> bool:
	return _indice_proxima_onda < _ondas_em_ordem.size() \
		and _ondas_em_ordem[_indice_proxima_onda].momento_segundos <= _tempo_decorrido_segundos


func _lancar_onda(onda: DadosOnda) -> void:
	if onda.tipo_inimigo == null:
		push_warning("Onda sem tipo de inimigo no momento %.1f s." % onda.momento_segundos)
		return
	var margem_lateral := _margem_lateral_para(onda.tipo_inimigo)
	for posicao in Formacoes.calcular_posicoes(onda, margem_lateral):
		spawn_solicitado.emit(onda.tipo_inimigo, posicao)


## Inimigos que oscilam precisam de mais folga nas bordas para não sair da tela.
func _margem_lateral_para(tipo_inimigo: DadosInimigo) -> float:
	if tipo_inimigo.movimento == DadosInimigo.Movimento.ZIGZAG:
		return MARGEM_LATERAL_MINIMA + tipo_inimigo.amplitude
	return MARGEM_LATERAL_MINIMA
