class_name Formacoes
extends RefCounted

## Calcula onde cada inimigo de uma onda nasce, conforme a formação.
## Todos nascem acima da tela (y negativo) e descem juntos, mantendo o desenho.

const LARGURA_DA_TELA := 480.0
const ALTURA_DE_ENTRADA := -30.0
const POSICAO_X_FLANCO_ESQUERDO := 70.0
const POSICAO_X_FLANCO_DIREITO := 410.0
## No V, cada passo para o lado recua esta fração do espaçamento para cima.
const RECUO_VERTICAL_DO_V := 0.7


static func calcular_posicoes(onda: DadosOnda, margem_lateral: float) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	match onda.formacao:
		DadosOnda.Formacao.LINHA:
			posicoes = _posicoes_em_linha(onda)
		DadosOnda.Formacao.V:
			posicoes = _posicoes_em_v(onda)
		DadosOnda.Formacao.FLANCOS:
			posicoes = _posicoes_nos_flancos(onda, margem_lateral)
	return _manter_dentro_da_tela(posicoes, margem_lateral)


static func _posicoes_em_linha(onda: DadosOnda) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	var largura_total := onda.espacamento * (onda.quantidade - 1)
	var primeira_posicao_x := onda.posicao_central_x - largura_total / 2.0
	for indice in onda.quantidade:
		posicoes.append(Vector2(primeira_posicao_x + indice * onda.espacamento, ALTURA_DE_ENTRADA))
	return posicoes


## A ponta do V vem na frente; as asas vêm atrás, alternando esquerda e direita.
static func _posicoes_em_v(onda: DadosOnda) -> Array[Vector2]:
	var posicoes: Array[Vector2] = [Vector2(onda.posicao_central_x, ALTURA_DE_ENTRADA)]
	for indice in range(1, onda.quantidade):
		var distancia_da_ponta := ceili(indice / 2.0)
		var lado := -1.0 if indice % 2 == 1 else 1.0
		posicoes.append(Vector2(
			onda.posicao_central_x + lado * distancia_da_ponta * onda.espacamento,
			ALTURA_DE_ENTRADA - distancia_da_ponta * onda.espacamento * RECUO_VERTICAL_DO_V))
	return posicoes


## Duas colunas, uma em cada lateral, deixando o centro livre (e encurralando quem fica nos cantos).
static func _posicoes_nos_flancos(onda: DadosOnda, margem_lateral: float) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	var posicao_x_esquerda := maxf(POSICAO_X_FLANCO_ESQUERDO, margem_lateral)
	var posicao_x_direita := minf(POSICAO_X_FLANCO_DIREITO, LARGURA_DA_TELA - margem_lateral)
	for indice in onda.quantidade:
		var posicao_x := posicao_x_esquerda if indice % 2 == 0 else posicao_x_direita
		var linha_da_coluna := indice / 2
		posicoes.append(Vector2(posicao_x, ALTURA_DE_ENTRADA - linha_da_coluna * onda.espacamento))
	return posicoes


static func _manter_dentro_da_tela(posicoes: Array[Vector2], margem_lateral: float) -> Array[Vector2]:
	var posicoes_ajustadas: Array[Vector2] = []
	for posicao in posicoes:
		posicoes_ajustadas.append(Vector2(
			clampf(posicao.x, margem_lateral, LARGURA_DA_TELA - margem_lateral), posicao.y))
	return posicoes_ajustadas
