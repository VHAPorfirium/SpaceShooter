class_name CatalogoFases
extends RefCounted

## Roteiro de cada fase, seguindo o GDD (introduzir -> combinar -> testar).
## Para balancear, mexa nos momentos, quantidades e espaçamentos abaixo.

const BATEDOR := preload("res://data/batedor.tres")
const SERPENTE := preload("res://data/serpente.tres")
const BASTIAO := preload("res://data/bastiao.tres")
const ASTEROIDE := preload("res://data/asteroide.tres")

const TIRO_DUPLO := preload("res://data/tiro_duplo.tres")
const TIRO_TRIPLO := preload("res://data/tiro_triplo.tres")
const ESCUDO := preload("res://data/escudo.tres")
const AJUDANTE := preload("res://data/ajudante.tres")

const SENTINELA := preload("res://scenes/sentinela.tscn")
const CEIFADOR := preload("res://scenes/ceifador.tscn")
const COLMEIA := preload("res://scenes/colmeia.tscn")

const MUSICA_FASE_1 := preload("res://assets/audio/musicas/fase_1.wav")
const MUSICA_FASE_2 := preload("res://assets/audio/musicas/fase_2.wav")
const MUSICA_FASE_3 := preload("res://assets/audio/musicas/fase_3.wav")
const MUSICA_CHEFE := preload("res://assets/audio/musicas/chefe.wav")

const LINHA := DadosOnda.Formacao.LINHA
const V := DadosOnda.Formacao.V
const FLANCOS := DadosOnda.Formacao.FLANCOS
const CENTRO := 240.0
const ESQUERDA := 140.0
const DIREITA := 340.0


## Órbita da Terra: só Batedores. Ensina a mover, atirar e desviar.
static func fase_1() -> DadosFase:
	var fase := DadosFase.new()
	fase.nome = "Fase 1: Órbita da Terra"
	fase.cor_fundo = Color("#0d1b3a")
	fase.cor_estrelas = Color("#9fc5ff")
	fase.frase_de_abertura = "A defesa orbital caiu.\nO último caça decola."
	fase.poderes.assign([TIRO_DUPLO, TIRO_TRIPLO])
	fase.chefe = SENTINELA
	fase.musica = MUSICA_FASE_1
	fase.musica_chefe = MUSICA_CHEFE
	fase.ondas.assign([
		# Bloco 1: apresentação, poucos inimigos e bem espaçados
		_onda(2.0, LINHA, BATEDOR, 3, 80.0, CENTRO),
		_onda(7.0, LINHA, BATEDOR, 3, 70.0, ESQUERDA),
		_onda(11.0, LINHA, BATEDOR, 3, 70.0, DIREITA),
		_onda(16.0, V, BATEDOR, 5, 45.0, CENTRO),
		_onda(23.0, LINHA, BATEDOR, 5, 60.0, CENTRO),
		_onda(28.0, FLANCOS, BATEDOR, 4, 60.0),
		# respiro
		# Bloco 2: formações em sequência
		_onda(38.0, V, BATEDOR, 5, 45.0, ESQUERDA),
		_onda(42.0, V, BATEDOR, 5, 45.0, DIREITA),
		_onda(48.0, LINHA, BATEDOR, 6, 65.0, CENTRO),
		_onda(53.0, FLANCOS, BATEDOR, 6, 55.0),
		# respiro
		# Bloco 3: ritmo mais rápido
		_onda(64.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(70.0, LINHA, BATEDOR, 4, 60.0, ESQUERDA),
		_onda(72.0, LINHA, BATEDOR, 4, 60.0, DIREITA),
		_onda(78.0, FLANCOS, BATEDOR, 6, 50.0),
		_onda(84.0, V, BATEDOR, 5, 45.0, CENTRO),
		# respiro
		# Bloco 4: teste antes do chefe
		_onda(96.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
		_onda(101.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(106.0, FLANCOS, BATEDOR, 8, 50.0),
		_onda(112.0, LINHA, BATEDOR, 5, 55.0, ESQUERDA),
		_onda(114.0, LINHA, BATEDOR, 5, 55.0, DIREITA),
	])
	return fase


## Cinturão de asteroides: Batedores e Serpentes. Ensina formações e movimento lateral.
## Asteroides (4 de vida, giram devagar) atravessam o caminho como perigo extra.
static func fase_2() -> DadosFase:
	var fase := DadosFase.new()
	fase.nome = "Fase 2: Cinturão de asteroides"
	fase.cor_fundo = Color("#2a1a12")
	fase.cor_estrelas = Color("#ffcf9f")
	fase.frase_de_abertura = "A frota recua para o cinturão\nde asteroides e se esconde\nentre as rochas."
	fase.poderes.assign([ESCUDO, AJUDANTE])
	fase.chefe = CEIFADOR
	fase.musica = MUSICA_FASE_2
	fase.musica_chefe = MUSICA_CHEFE
	fase.ondas.assign([
		# Bloco 1: apresenta a Serpente sozinha, depois mistura
		_onda(2.0, LINHA, SERPENTE, 3, 90.0, CENTRO),
		_onda(8.0, V, BATEDOR, 5, 45.0, CENTRO),
		_onda(13.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(19.0, FLANCOS, BATEDOR, 6, 55.0),
		_onda(22.0, LINHA, ASTEROIDE, 1, 0.0, 130.0),
		# respiro
		# Bloco 2
		_onda(28.0, V, SERPENTE, 5, 55.0, CENTRO),
		_onda(34.0, LINHA, BATEDOR, 6, 65.0, CENTRO),
		_onda(36.0, LINHA, SERPENTE, 3, 90.0, CENTRO),
		_onda(42.0, FLANCOS, SERPENTE, 4, 70.0),
		_onda(48.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(52.0, LINHA, ASTEROIDE, 2, 220.0, CENTRO),
		# respiro
		# Bloco 3
		_onda(60.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(64.0, V, BATEDOR, 5, 45.0, ESQUERDA),
		_onda(66.0, V, BATEDOR, 5, 45.0, DIREITA),
		_onda(72.0, FLANCOS, SERPENTE, 6, 65.0),
		_onda(75.0, LINHA, ASTEROIDE, 1, 0.0, CENTRO),
		_onda(78.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
		_onda(80.0, V, SERPENTE, 5, 55.0, CENTRO),
		# respiro
		# Bloco 4
		_onda(92.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(95.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(100.0, FLANCOS, BATEDOR, 8, 50.0),
		_onda(104.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(107.0, LINHA, ASTEROIDE, 2, 200.0, CENTRO),
		_onda(110.0, V, SERPENTE, 7, 45.0, CENTRO),
		# respiro
		# Bloco 5: teste antes do chefe
		_onda(122.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
		_onda(125.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
		_onda(128.0, FLANCOS, SERPENTE, 6, 65.0),
		_onda(130.0, LINHA, ASTEROIDE, 1, 0.0, 340.0),
		_onda(133.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(135.0, V, SERPENTE, 5, 55.0, CENTRO),
		_onda(140.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(142.0, FLANCOS, BATEDOR, 8, 50.0),
		# respiro curto
		# Bloco 6: rajada final, tudo junto
		_onda(152.0, V, SERPENTE, 7, 45.0, CENTRO),
		_onda(155.0, LINHA, BATEDOR, 4, 60.0, ESQUERDA),
		_onda(157.0, LINHA, BATEDOR, 4, 60.0, DIREITA),
		_onda(161.0, FLANCOS, SERPENTE, 6, 65.0),
		_onda(164.0, V, BATEDOR, 7, 40.0, CENTRO),
	])
	return fase



## Nave-Mãe: os três inimigos. Ensina tiros inimigos e prioridade de alvos:
## os Bastiões (lentos, 3 de vida, atiram) vêm escoltados por Batedores rápidos.
static func fase_3() -> DadosFase:
	var fase := DadosFase.new()
	fase.nome = "Fase 3: Nave-Mãe"
	fase.cor_fundo = Color("#2b0d24")
	fase.cor_estrelas = Color("#ff9fd8")
	fase.frase_de_abertura = "A Nave-Mãe Colmeia\nse aproxima da Terra.\nÉ agora ou nunca."
	fase.poderes.assign([TIRO_DUPLO, TIRO_TRIPLO, ESCUDO, AJUDANTE])
	fase.chefe = COLMEIA
	fase.musica = MUSICA_FASE_3
	fase.musica_chefe = MUSICA_CHEFE
	fase.ondas.assign([
		# Bloco 1: apresenta o Bastião, poucos e bem separados
		_onda(2.0, LINHA, BASTIAO, 2, 160.0, CENTRO),
		_onda(9.0, V, BATEDOR, 5, 45.0, CENTRO),
		_onda(13.0, LINHA, BASTIAO, 3, 120.0, CENTRO),
		_onda(19.0, FLANCOS, SERPENTE, 4, 70.0),
		# respiro
		# Bloco 2: Bastiões com escolta (quem derrubar primeiro?)
		_onda(30.0, LINHA, BASTIAO, 3, 120.0, CENTRO),
		_onda(32.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(38.0, FLANCOS, BASTIAO, 4, 70.0),
		_onda(44.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(48.0, V, BATEDOR, 5, 45.0, ESQUERDA),
		_onda(50.0, V, BATEDOR, 5, 45.0, DIREITA),
		# respiro
		# Bloco 3: chuva de projéteis
		_onda(62.0, LINHA, BASTIAO, 5, 90.0, CENTRO),
		_onda(66.0, V, SERPENTE, 5, 55.0, CENTRO),
		_onda(72.0, FLANCOS, BATEDOR, 8, 50.0),
		_onda(76.0, V, BASTIAO, 3, 70.0, CENTRO),
		_onda(82.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
		# respiro
		# Bloco 4: prioridade de alvos
		_onda(94.0, LINHA, BASTIAO, 4, 100.0, CENTRO),
		_onda(95.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(100.0, FLANCOS, SERPENTE, 6, 65.0),
		_onda(106.0, LINHA, BASTIAO, 3, 60.0, ESQUERDA),
		_onda(108.0, LINHA, BASTIAO, 3, 60.0, DIREITA),
		_onda(112.0, V, BATEDOR, 7, 40.0, CENTRO),
		# respiro
		# Bloco 5: teste final antes da Colmeia
		_onda(124.0, V, BASTIAO, 5, 55.0, CENTRO),
		_onda(127.0, LINHA, SERPENTE, 4, 90.0, CENTRO),
		_onda(131.0, FLANCOS, BATEDOR, 8, 50.0),
		_onda(135.0, LINHA, BASTIAO, 5, 90.0, CENTRO),
		_onda(138.0, V, SERPENTE, 7, 45.0, CENTRO),
		_onda(142.0, V, BATEDOR, 7, 40.0, CENTRO),
		_onda(146.0, FLANCOS, BASTIAO, 4, 70.0),
		_onda(150.0, LINHA, BATEDOR, 7, 60.0, CENTRO),
	])
	return fase


static func _onda(momento_segundos: float, formacao: DadosOnda.Formacao, tipo_inimigo: DadosInimigo,
		quantidade: int, espacamento: float, posicao_central_x: float = CENTRO) -> DadosOnda:
	var onda := DadosOnda.new()
	onda.momento_segundos = momento_segundos
	onda.formacao = formacao
	onda.tipo_inimigo = tipo_inimigo
	onda.quantidade = quantidade
	onda.espacamento = espacamento
	onda.posicao_central_x = posicao_central_x
	return onda
