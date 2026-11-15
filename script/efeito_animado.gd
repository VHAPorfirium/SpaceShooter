class_name EfeitoAnimado
extends AnimatedSprite2D

## Efeito visual de quadros (explosão, faísca de acerto) que toca uma vez e se remove.


## quadros: animação "default" sem repetição; tamanho_na_tela: tamanho final do efeito;
## duracao_segundos: tempo total da animação, qualquer que seja o número de quadros.
static func criar(posicao: Vector2, quadros: SpriteFrames, tamanho_na_tela: Vector2, duracao_segundos: float) -> EfeitoAnimado:
	var efeito := EfeitoAnimado.new()
	efeito.position = posicao
	efeito.sprite_frames = quadros
	var tamanho_do_quadro := quadros.get_frame_texture(&"default", 0).get_size()
	efeito.scale = tamanho_na_tela / tamanho_do_quadro
	efeito.speed_scale = quadros.get_frame_count(&"default") / (quadros.get_animation_speed(&"default") * duracao_segundos)
	return efeito


func _ready() -> void:
	z_index = 10
	animation_finished.connect(queue_free)
	play(&"default")
