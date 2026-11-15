class_name FundoEstrelado
extends Node2D

## Campo de estrelas que rola para baixo em 3 camadas (efeito parallax):
## estrelas distantes são pequenas, apagadas e lentas; as próximas são maiores e rápidas.
## Dá a sensação de que a nave avança pelo espaço, mesmo com a câmera parada.

const TAMANHO_DA_TELA := Vector2(480.0, 720.0)

## Cada camada: quantidade de estrelas, velocidade (px/s), raio (px) e opacidade.
const CAMADAS := [
	{"quantidade": 60, "velocidade": 25.0, "raio": 0.8, "opacidade": 0.35},
	{"quantidade": 35, "velocidade": 60.0, "raio": 1.3, "opacidade": 0.6},
	{"quantidade": 15, "velocidade": 130.0, "raio": 1.9, "opacidade": 0.9},
]

@export var cor_das_estrelas: Color = Color("#c9d6ff")

var _estrelas: Array[Dictionary] = []


func _ready() -> void:
	z_index = -100  # sempre atrás de tudo
	for indice_camada in CAMADAS.size():
		var camada: Dictionary = CAMADAS[indice_camada]
		for indice in camada["quantidade"]:
			_estrelas.append({
				"posicao": Vector2(randf() * TAMANHO_DA_TELA.x, randf() * TAMANHO_DA_TELA.y),
				"camada": indice_camada,
			})


func definir_cor_das_estrelas(nova_cor: Color) -> void:
	cor_das_estrelas = nova_cor
	queue_redraw()


func _process(delta: float) -> void:
	for estrela in _estrelas:
		var camada: Dictionary = CAMADAS[estrela["camada"]]
		var posicao: Vector2 = estrela["posicao"]
		posicao.y += camada["velocidade"] * delta
		if posicao.y > TAMANHO_DA_TELA.y:
			# Saiu por baixo: volta por cima, numa coluna nova, para não repetir o desenho
			posicao = Vector2(randf() * TAMANHO_DA_TELA.x, posicao.y - TAMANHO_DA_TELA.y)
		estrela["posicao"] = posicao
	queue_redraw()


func _draw() -> void:
	for estrela in _estrelas:
		var camada: Dictionary = CAMADAS[estrela["camada"]]
		var cor := Color(cor_das_estrelas, camada["opacidade"])
		draw_circle(estrela["posicao"], camada["raio"], cor)
