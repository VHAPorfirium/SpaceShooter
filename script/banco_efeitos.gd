class_name BancoEfeitos
extends Node

## Guarda um AudioStreamPlayer por efeito sonoro e toca cada um sob demanda.
## Limita quantos sons iguais tocam juntos e ignora repetições muito próximas,
## para que vários tiros no mesmo quadro não virem um estouro de volume.

const MAXIMO_DE_SONS_IGUAIS_SIMULTANEOS := 6
const INTERVALO_MINIMO_ENTRE_REPETICOES_MS := 40

var _tocador_por_efeito: Dictionary = {}
var _ultimo_instante_tocado_por_efeito_ms: Dictionary = {}


func registrar_efeito(identificador_efeito: int, som: AudioStream, nome_barramento: StringName) -> void:
	var tocador := AudioStreamPlayer.new()
	tocador.stream = som
	tocador.bus = nome_barramento
	tocador.max_polyphony = MAXIMO_DE_SONS_IGUAIS_SIMULTANEOS
	add_child(tocador)
	_tocador_por_efeito[identificador_efeito] = tocador


func tocar(identificador_efeito: int) -> void:
	var tocador: AudioStreamPlayer = _tocador_por_efeito.get(identificador_efeito)
	if tocador == null:
		push_warning("Efeito sonoro não registrado: %d" % identificador_efeito)
		return

	var instante_atual_ms := Time.get_ticks_msec()
	var ultimo_instante_ms: int = _ultimo_instante_tocado_por_efeito_ms.get(identificador_efeito, -INTERVALO_MINIMO_ENTRE_REPETICOES_MS)
	if instante_atual_ms - ultimo_instante_ms < INTERVALO_MINIMO_ENTRE_REPETICOES_MS:
		return
	_ultimo_instante_tocado_por_efeito_ms[identificador_efeito] = instante_atual_ms
	tocador.play()


func parar_todos() -> void:
	for tocador: AudioStreamPlayer in _tocador_por_efeito.values():
		tocador.stop()
