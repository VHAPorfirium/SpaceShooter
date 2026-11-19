class_name DadosOnda
extends Resource

## Ficha de uma onda do roteiro: em tal momento, tal formação de tal inimigo.

enum Formacao { LINHA, V, FLANCOS, DISPERSA, DIAGONAL_ESQ, DIAGONAL_DIR, ARCO }

## Segundos desde o início da fase em que a onda entra em cena.
@export var momento_segundos: float = 0.0
@export var formacao: Formacao = Formacao.LINHA
@export var tipo_inimigo: DadosInimigo
@export var quantidade: int = 3
## Distância em pixels entre um inimigo e o próximo da formação.
@export var espacamento: float = 60.0
## Centro horizontal da formação (a tela tem 480 de largura). Ignorado em FLANCOS.
@export var posicao_central_x: float = 240.0
