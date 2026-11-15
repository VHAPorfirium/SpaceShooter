class_name DadosFase
extends Resource

@export var nome: String = "Fase"
@export var cor_fundo: Color = Color("#14102b")
## Roteiro da fase: cada onda entra no seu momento; os intervalos vazios são as pausas de respiro.
@export var ondas: Array[DadosOnda] = []
## Poderes que podem cair dos inimigos nesta fase.
@export var poderes: Array[DadosPoder] = []
@export var chefe: PackedScene
@export var musica: AudioStream
@export var musica_chefe: AudioStream
