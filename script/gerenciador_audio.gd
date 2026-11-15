extends Node

## Ponto único de áudio do jogo (Autoload "GerenciadorAudio").
## As cenas só pedem "toque tal efeito" ou "toque tal música";
## quem sabe COMO tocar são o TocadorMusica e o BancoEfeitos.

enum Efeito {
	TIRO_JOGADOR,
	TIRO_INIMIGO,
	EXPLOSAO_INIMIGO,
	ACERTO_CHEFE,
	EXPLOSAO_CHEFE,
	DANO_JOGADOR,
	PODER_COLETADO,
	AVISO_CHEFE,
	CONFIRMAR,
	FASE_CONCLUIDA,
	VITORIA,
	FIM_DE_JOGO,
}

const SOM_POR_EFEITO := {
	Efeito.TIRO_JOGADOR: preload("res://assets/audio/efeitos/tiro_jogador.wav"),
	Efeito.TIRO_INIMIGO: preload("res://assets/audio/efeitos/tiro_inimigo.wav"),
	Efeito.EXPLOSAO_INIMIGO: preload("res://assets/audio/efeitos/explosao_inimigo.wav"),
	Efeito.ACERTO_CHEFE: preload("res://assets/audio/efeitos/acerto_chefe.wav"),
	Efeito.EXPLOSAO_CHEFE: preload("res://assets/audio/efeitos/explosao_chefe.wav"),
	Efeito.DANO_JOGADOR: preload("res://assets/audio/efeitos/dano_jogador.wav"),
	Efeito.PODER_COLETADO: preload("res://assets/audio/efeitos/poder_coletado.wav"),
	Efeito.AVISO_CHEFE: preload("res://assets/audio/efeitos/aviso_chefe.wav"),
	Efeito.CONFIRMAR: preload("res://assets/audio/efeitos/confirmar.wav"),
	Efeito.FASE_CONCLUIDA: preload("res://assets/audio/efeitos/fase_concluida.wav"),
	Efeito.VITORIA: preload("res://assets/audio/efeitos/vitoria.wav"),
	Efeito.FIM_DE_JOGO: preload("res://assets/audio/efeitos/fim_de_jogo.wav"),
}

const NOME_BARRAMENTO_MUSICA := &"Musica"
const NOME_BARRAMENTO_EFEITOS := &"Efeitos"
const REDUCAO_VOLUME_MUSICA_PAUSADO_DB := 12.0

var _tocador_musica: TocadorMusica
var _banco_efeitos: BancoEfeitos
var _volume_normal_musica_db: float = 0.0
var _musica_abaixada_pela_pausa: bool = false


func _ready() -> void:
	_tocador_musica = TocadorMusica.new()
	_tocador_musica.bus = _barramento_ou_master(NOME_BARRAMENTO_MUSICA)
	add_child(_tocador_musica)

	_banco_efeitos = BancoEfeitos.new()
	add_child(_banco_efeitos)
	var barramento_efeitos := _barramento_ou_master(NOME_BARRAMENTO_EFEITOS)
	for efeito: Efeito in SOM_POR_EFEITO:
		_banco_efeitos.registrar_efeito(efeito, SOM_POR_EFEITO[efeito], barramento_efeitos)

	var indice_barramento_musica := AudioServer.get_bus_index(NOME_BARRAMENTO_MUSICA)
	if indice_barramento_musica != -1:
		_volume_normal_musica_db = AudioServer.get_bus_volume_db(indice_barramento_musica)


func tocar_musica(musica: AudioStream) -> void:
	_tocador_musica.tocar(musica)


func parar_musica() -> void:
	_tocador_musica.parar()


func tocar_efeito(efeito: Efeito) -> void:
	_banco_efeitos.tocar(efeito)


## Toca um efeito de encerramento (vitória, fim de jogo, fase concluída) no lugar da música.
func tocar_encerramento(efeito: Efeito) -> void:
	parar_musica()
	tocar_efeito(efeito)


func definir_jogo_pausado(pausado: bool) -> void:
	if pausado == _musica_abaixada_pela_pausa:
		return
	_musica_abaixada_pela_pausa = pausado
	var indice_barramento_musica := AudioServer.get_bus_index(NOME_BARRAMENTO_MUSICA)
	if indice_barramento_musica == -1:
		return
	var volume_desejado_db := _volume_normal_musica_db
	if pausado:
		volume_desejado_db -= REDUCAO_VOLUME_MUSICA_PAUSADO_DB
	AudioServer.set_bus_volume_db(indice_barramento_musica, volume_desejado_db)


func _barramento_ou_master(nome_barramento: StringName) -> StringName:
	if AudioServer.get_bus_index(nome_barramento) == -1:
		push_warning("Barramento de áudio '%s' não existe; usando Master." % nome_barramento)
		return &"Master"
	return nome_barramento
