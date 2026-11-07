class_name Recorde
extends RefCounted

const CAMINHO := "user://recorde.cfg"


static func carregar() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(CAMINHO) != OK:
		return 0  # ainda não existe arquivo: sem recorde
	return int(cfg.get_value("jogo", "recorde", 0))


static func salvar(pontos: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("jogo", "recorde", pontos)
	cfg.save(CAMINHO)
