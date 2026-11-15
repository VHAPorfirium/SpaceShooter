class_name FlashDeDano
extends ColorRect

## Pisca a tela de vermelho quando o jogador leva dano.

@export var opacidade_inicial: float = 0.35
@export var duracao_segundos: float = 0.35

var _animacao: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(1.0, 0.15, 0.2, 0.0)
	z_index = 50


func piscar() -> void:
	if _animacao != null:
		_animacao.kill()
	color.a = opacidade_inicial
	_animacao = create_tween()
	_animacao.tween_property(self, "color:a", 0.0, duracao_segundos)
