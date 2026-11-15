class_name TiroInimigo
extends Area2D

@export var velocidade: float = 230.0
## Arte do tiro. Vazio = losango branco.
@export var textura: Texture2D

var direcao: Vector2 = Vector2.DOWN


func _ready() -> void:
	$Desenho.polygon = PackedVector2Array([
		Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)])
	$Desenho.color = Color("#ffffff")
	$Imagem.exibir(textura, $Forma.shape.size, [$Desenho])
	$Notificador.screen_exited.connect(queue_free)


func _process(delta: float) -> void:
	position += direcao * velocidade * delta
