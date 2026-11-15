class_name DadosCamadaCenario
extends Resource

## Uma camada do cenário de fundo de uma fase (fundo, estrelas, rochas...).
## Camadas mais "perto" rolam mais rápido, dando sensação de profundidade (parallax).

## Imagem de 480 x 720 que se repete na vertical sem emenda.
@export var textura: Texture2D
## Velocidade da rolagem para baixo, em pixels por segundo.
@export var velocidade_px_por_segundo: float = 50.0
