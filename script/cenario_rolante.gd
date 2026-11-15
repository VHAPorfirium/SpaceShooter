class_name CenarioRolante
extends Node2D

## Desenha as camadas do cenário da fase rolando para baixo, cada uma na sua velocidade.
## Cada camada é desenhada duas vezes, uma em cima da outra, para a emenda nunca aparecer.

const TAMANHO_DA_TELA := Vector2(480.0, 720.0)

var _camadas: Array[DadosCamadaCenario] = []
var _deslocamentos_verticais: Array[float] = []


func _ready() -> void:
	z_index = -100  # sempre atrás de tudo
	visible = false


func definir_camadas(camadas: Array[DadosCamadaCenario]) -> void:
	_camadas.assign(camadas.filter(func(camada: DadosCamadaCenario) -> bool: return camada.textura != null))
	_deslocamentos_verticais.assign(_camadas.map(func(_camada) -> float: return 0.0))
	visible = tem_camadas()
	queue_redraw()


func tem_camadas() -> bool:
	return not _camadas.is_empty()


func _process(delta: float) -> void:
	if not tem_camadas():
		return
	for indice in _camadas.size():
		var novo_deslocamento := _deslocamentos_verticais[indice] + _camadas[indice].velocidade_px_por_segundo * delta
		_deslocamentos_verticais[indice] = fposmod(novo_deslocamento, TAMANHO_DA_TELA.y)
	queue_redraw()


func _draw() -> void:
	for indice in _camadas.size():
		var textura := _camadas[indice].textura
		var deslocamento := _deslocamentos_verticais[indice]
		draw_texture_rect(textura, Rect2(Vector2(0.0, deslocamento - TAMANHO_DA_TELA.y), TAMANHO_DA_TELA), false)
		draw_texture_rect(textura, Rect2(Vector2(0.0, deslocamento), TAMANHO_DA_TELA), false)
