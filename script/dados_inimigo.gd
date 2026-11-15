class_name DadosInimigo
extends Resource

enum Movimento { RETO, ZIGZAG }
enum Forma { TRIANGULO, SETA, BLOCO, ROCHA }

@export var nome: String = "Batedor"
## Arte do inimigo. Vazio = usa o desenho geométrico (forma e cor abaixo).
@export var textura: Texture2D
@export var vida: int = 1
@export var velocidade: float = 110.0
@export var pontos: int = 10
@export var cor: Color = Color("#ff5d73")
@export var forma: Forma = Forma.TRIANGULO
@export var tamanho: Vector2 = Vector2(30, 28)
@export var movimento: Movimento = Movimento.RETO
@export var amplitude: float = 70.0
@export var frequencia: float = 3.0
@export var atira: bool = false
@export var intervalo_tiro: float = 1.4
## Giro do desenho em radianos por segundo (asteroides). 0 = não gira.
@export var velocidade_giro: float = 0.0
