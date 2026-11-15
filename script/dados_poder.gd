class_name DadosPoder
extends Resource

enum Tipo { TIRO_DUPLO, TIRO_TRIPLO, ESCUDO, AJUDANTE }

@export var nome: String = "Poder"
## Ícone do item. Vazio = círculo colorido com o rótulo.
@export var textura: Texture2D
@export var tipo: Tipo = Tipo.TIRO_DUPLO
@export var duracao: float = 8.0
@export var cor: Color = Color("#ffd166")
@export var rotulo: String = "2x"
