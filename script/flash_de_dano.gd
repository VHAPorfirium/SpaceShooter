class_name FlashDeDano
extends ColorRect

## Pisca a tela quando o jogador leva dano.
## Com textura: mostra a borda vermelha da arte (vinheta). Sem textura: tela inteira avermelhada (plano B).

## Arte da borda de dano. Vazio = retângulo vermelho translúcido.
@export var textura: Texture2D
@export var opacidade_inicial_sem_textura: float = 0.35
@export var duracao_segundos: float = 0.35

var _animacao: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 50
	modulate.a = 0.0
	# Com arte, o retângulo fica transparente e só a textura aparece (em _draw)
	color = Color(1.0, 1.0, 1.0, 0.0) if textura != null else Color(1.0, 0.15, 0.2, 1.0)


func piscar() -> void:
	if _animacao != null:
		_animacao.kill()
	modulate.a = 1.0 if textura != null else opacidade_inicial_sem_textura
	_animacao = create_tween()
	_animacao.tween_property(self, "modulate:a", 0.0, duracao_segundos)


func _draw() -> void:
	if textura != null:
		draw_texture_rect(textura, Rect2(Vector2.ZERO, size), false)
