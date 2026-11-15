extends Node2D

## Nave de ajuda que acompanha o jogador.

const TAMANHO_NA_TELA := Vector2(18, 21)

## Arte da nave de ajuda. Vazio = desenho geométrico.
@export var textura: Texture2D


func _ready() -> void:
	$Desenho.polygon = PackedVector2Array([
		Vector2(0, -11), Vector2(9, 10), Vector2(3, 6),
		Vector2(-3, 6), Vector2(-9, 10)])
	$Desenho.color = Color("#ff8fd1")
	$Imagem.exibir(textura, TAMANHO_NA_TELA, [$Desenho])
