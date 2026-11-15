class_name DadosFase
extends Resource

@export var nome: String = "Fase"
@export var cor_fundo: Color = Color("#14102b")
@export var cor_estrelas: Color = Color("#c9d6ff")
## Camadas do cenário, da mais distante para a mais próxima. Vazio = fundo de estrelas em código.
@export var camadas_do_cenario: Array[DadosCamadaCenario] = []
## Frase curta de história mostrada quando a fase começa (na tela de transição).
@export_multiline var frase_de_abertura: String = ""
## Roteiro da fase: cada onda entra no seu momento; os intervalos vazios são as pausas de respiro.
@export var ondas: Array[DadosOnda] = []
## Poderes que podem cair dos inimigos nesta fase.
@export var poderes: Array[DadosPoder] = []
@export var chefe: PackedScene
@export var musica: AudioStream
@export var musica_chefe: AudioStream
