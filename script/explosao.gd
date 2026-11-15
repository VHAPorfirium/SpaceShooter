class_name Explosao
extends Node2D

## Explosão simples desenhada em código: um clarão, um anel que cresce
## e estilhaços que voam para fora, tudo sumindo aos poucos. Remove-se sozinha.

@export var raio_final: float = 26.0
@export var duracao_segundos: float = 0.45
@export var cor: Color = Color("#ffd166")
@export var quantidade_de_estilhacos: int = 8

var _tempo_decorrido: float = 0.0
var _direcoes_dos_estilhacos: Array[Vector2] = []


static func criar(posicao: Vector2, cor_da_explosao: Color, raio: float, duracao: float) -> Explosao:
	var explosao := Explosao.new()
	explosao.position = posicao
	explosao.cor = cor_da_explosao
	explosao.raio_final = raio
	explosao.duracao_segundos = duracao
	explosao.quantidade_de_estilhacos = 8 if raio < 60.0 else 16
	return explosao


func _ready() -> void:
	z_index = 10
	for indice in quantidade_de_estilhacos:
		var angulo := TAU * indice / quantidade_de_estilhacos + randf_range(-0.3, 0.3)
		_direcoes_dos_estilhacos.append(Vector2.RIGHT.rotated(angulo) * randf_range(0.7, 1.2))


func _process(delta: float) -> void:
	_tempo_decorrido += delta
	if _tempo_decorrido >= duracao_segundos:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progresso := _tempo_decorrido / duracao_segundos
	var opacidade := 1.0 - progresso
	var raio_atual := raio_final * ease(progresso, 0.4)

	# Clarão branco no centro, só no começo
	if progresso < 0.35:
		draw_circle(Vector2.ZERO, raio_final * 0.5 * (1.0 - progresso / 0.35), Color(1, 1, 1, 0.9))
	# Anel de choque
	draw_arc(Vector2.ZERO, raio_atual, 0.0, TAU, 32, Color(cor, opacidade), maxf(1.0, 4.0 * opacidade))
	# Estilhaços
	for direcao in _direcoes_dos_estilhacos:
		var ponta := direcao * raio_atual * 1.3
		draw_line(ponta * 0.75, ponta, Color(cor.lightened(0.3), opacidade), 2.0)
