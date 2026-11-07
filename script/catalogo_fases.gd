class_name CatalogoFases
extends RefCounted

const BATEDOR := preload("res://data/batedor.tres")
const SERPENTE := preload("res://data/serpente.tres")
const BASTIAO := preload("res://data/bastiao.tres")
const SENTINELA := preload("res://scenes/sentinela.tscn")


static func fase_1() -> DadosFase:
	var f := DadosFase.new()
	f.nome = "Fase 1: Órbita da Terra"
	f.cor_fundo = Color("#0d1b3a")
	f.duracao = 150.0
	f.intervalo_inicial = 1.4
	f.intervalo_final = 0.9
	f.tipos.assign([BATEDOR, BATEDOR, BATEDOR, SERPENTE, BASTIAO])
	f.chefe = SENTINELA
	return f


static func fase_2() -> DadosFase:
	var f := DadosFase.new()
	f.nome = "Fase 2: Cinturão de asteroides"
	f.cor_fundo = Color("#2a1a12")
	f.duracao = 180.0
	f.intervalo_inicial = 1.1
	f.intervalo_final = 0.5
	f.tipos.assign([BATEDOR, BATEDOR, SERPENTE, SERPENTE, BASTIAO, BASTIAO])
	return f
