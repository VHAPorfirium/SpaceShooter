class_name TocadorMusica
extends AudioStreamPlayer

## Toca uma faixa de música por vez, no barramento de música.
## A música continua tocando com o jogo pausado (só fica mais baixa).


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func tocar(musica: AudioStream) -> void:
	if musica == null:
		parar()
		return
	var mesma_musica_ja_tocando := stream == musica and playing
	if mesma_musica_ja_tocando:
		return  # evita recomeçar a faixa ao reiniciar a partida
	stream = musica
	play()


func parar() -> void:
	stop()
	stream = null
