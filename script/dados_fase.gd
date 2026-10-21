class_name DadosFase
extends Resource

@export var nome: String = "Fase"
@export var cor_fundo: Color = Color("#14102b")
@export var duracao: float = 60.0
@export var intervalo_inicial: float = 1.4
@export var intervalo_final: float = 0.8
@export var tipos: Array[DadosInimigo] = []
@export var chefe: PackedScene
