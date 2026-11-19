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
		DadosOnda.Formacao.DISPERSA:
			posicoes = _posicoes_dispersas(onda, margem_lateral)
		DadosOnda.Formacao.DIAGONAL_ESQ:
			posicoes = _posicoes_em_diagonal(onda, -1.0)
		DadosOnda.Formacao.DIAGONAL_DIR:
			posicoes = _posicoes_em_diagonal(onda, 1.0)
		DadosOnda.Formacao.ARCO:
			posicoes = _posicoes_em_arco(onda)

	# Adiciona leve variação orgânica (jitter) para não ficarem mecanicamente idênticos
	for i in posicoes.size():
		var variacao_x := randf_range(-8.0, 8.0)
		var variacao_y := randf_range(-10.0, 10.0)
		posicoes[i] += Vector2(variacao_x, variacao_y)

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


## Formação quase aleatória / dispersa: cobre a tela de forma orgânica e imprevisível.
static func _posicoes_dispersas(onda: DadosOnda, margem_lateral: float) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	var largura_util := (LARGURA_DA_TELA - margem_lateral * 2.0)
	var passo_x := largura_util / float(maxi(onda.quantidade, 1))
	for indice in onda.quantidade:
		var base_x := margem_lateral + (indice + 0.5) * passo_x + randf_range(-passo_x * 0.35, passo_x * 0.35)
		var entrada_y := ALTURA_DE_ENTRADA - randf_range(0.0, 70.0)
		posicoes.append(Vector2(base_x, entrada_y))
	return posicoes


## Formação diagonal (escadinha vindo de um lado para o outro).
static func _posicoes_em_diagonal(onda: DadosOnda, direcao: float) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	var largura_total := onda.espacamento * (onda.quantidade - 1)
	var inicio_x := onda.posicao_central_x - (largura_total / 2.0) * direcao
	for indice in onda.quantidade:
		var x := inicio_x + indice * onda.espacamento * direcao
		var y := ALTURA_DE_ENTRADA - indice * (onda.espacamento * 0.6)
		posicoes.append(Vector2(x, y))
	return posicoes


## Formação em arco (curvatura suave cercando a nave).
static func _posicoes_em_arco(onda: DadosOnda, raio: float = 120.0) -> Array[Vector2]:
	var posicoes: Array[Vector2] = []
	var angulo_total := PI * 0.55
	for indice in onda.quantidade:
		var fracao := 0.5 if onda.quantidade <= 1 else float(indice) / float(onda.quantidade - 1)
		var angulo := lerpf(-angulo_total / 2.0, angulo_total / 2.0, fracao)
		var x := onda.posicao_central_x + sin(angulo) * raio
		var y := ALTURA_DE_ENTRADA - (1.0 - cos(angulo)) * (raio * 0.7)
		posicoes.append(Vector2(x, y))
	return posicoes


static func _manter_dentro_da_tela(posicoes: Array[Vector2], margem_lateral: float) -> Array[Vector2]:
	var posicoes_ajustadas: Array[Vector2] = []
	for posicao in posicoes:
		posicoes_ajustadas.append(Vector2(
			clampf(posicao.x, margem_lateral, LARGURA_DA_TELA - margem_lateral), posicao.y))
	return posicoes_ajustadas

