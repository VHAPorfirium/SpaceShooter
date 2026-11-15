class_name PainelDeMensagem
extends Control

## Telas de texto por cima do jogo: abertura da fase, transição entre fases e resultado (vitória ou fim).
## Com as molduras da arte, cada texto cai dentro do seu quadro; sem elas (plano B), só os textos aparecem.

const TAMANHO_DA_TELA := Vector2(480, 720)
const FONTE_DAS_FRASES := preload("res://assets/fontes/ChakraPetch-Regular.ttf")
const FONTE_DAS_FRASES_EM_DESTAQUE := preload("res://assets/fontes/ChakraPetch-SemiBold.ttf")
const COR_DO_CONTORNO := Color("#0a0818")
const COR_TITULO_TRANSICAO := Color("#c9c3ff")
const COR_TITULO_VITORIA := Color("#ffd166")
const COR_TITULO_FIM_DE_JOGO := Color("#ff5d73")
const COR_TEXTO := Color("#f4f1ff")
const COR_TEXTO_SECUNDARIO := Color("#a89fd6")

## Posições tiradas das molduras do Claude Design (tela_transicao.svg, tela_vitoria.svg, tela_fim_de_jogo.svg).
const AREA_TITULO_TRANSICAO := Rect2(56, 246, 368, 60)
const AREA_FRASE_TRANSICAO := Rect2(64, 320, 352, 96)
const AREA_RODAPE_TRANSICAO := Rect2(64, 418, 352, 28)
const AREA_TITULO_RESULTADO := Rect2(52, 196, 376, 60)
const AREA_FRASE_RESULTADO := Rect2(52, 266, 376, 30)
const AREA_PONTOS := Rect2(72, 300, 348, 76)
const AREA_RECORDE := Rect2(72, 396, 348, 76)
const AREA_NOVO_RECORDE := Rect2(52, 478, 376, 26)
const AREA_INSTRUCOES := Rect2(52, 548, 376, 52)

@export var moldura_de_transicao: Texture2D
@export var moldura_de_vitoria: Texture2D
@export var moldura_de_fim_de_jogo: Texture2D

var _moldura: TextureRect
var _titulo: Label
var _frase: Label
var _rodape: Label
var _pontos: Label
var _recorde: Label
var _novo_recorde: Label
var _instrucoes: Label


func _ready() -> void:
	position = Vector2.ZERO
	size = TAMANHO_DA_TELA
	z_index = 55
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moldura = TextureRect.new()
	_moldura.size = TAMANHO_DA_TELA
	_moldura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_moldura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_moldura)
	_titulo = _criar_rotulo(18, null)
	_frase = _criar_rotulo(20, FONTE_DAS_FRASES)
	_rodape = _criar_rotulo(14, null)
	_pontos = _criar_rotulo(24, null)
	_recorde = _criar_rotulo(20, null)
	_novo_recorde = _criar_rotulo(18, FONTE_DAS_FRASES_EM_DESTAQUE)
	_instrucoes = _criar_rotulo(17, FONTE_DAS_FRASES)
	esconder()


func mostrar_abertura_de_fase(nome_da_fase: String, frase_de_historia: String) -> void:
	_preparar(moldura_de_transicao)
	_escrever(_titulo, nome_da_fase, AREA_TITULO_TRANSICAO, COR_TITULO_TRANSICAO)
	_escrever(_frase, frase_de_historia, AREA_FRASE_TRANSICAO, COR_TEXTO)


func mostrar_transicao(fase_concluida: String, frase_da_proxima_fase: String, nome_da_proxima_fase: String) -> void:
	_preparar(moldura_de_transicao)
	_escrever(_titulo, "%s concluída!" % fase_concluida, AREA_TITULO_TRANSICAO, COR_TITULO_TRANSICAO)
	_escrever(_frase, frase_da_proxima_fase, AREA_FRASE_TRANSICAO, COR_TEXTO)
	_escrever(_rodape, nome_da_proxima_fase, AREA_RODAPE_TRANSICAO, COR_TEXTO_SECUNDARIO)


func mostrar_resultado(eh_vitoria: bool, frase: String, pontos: int, recorde: int, eh_novo_recorde: bool) -> void:
	_preparar(moldura_de_vitoria if eh_vitoria else moldura_de_fim_de_jogo)
	var cor_do_titulo := COR_TITULO_VITORIA if eh_vitoria else COR_TITULO_FIM_DE_JOGO
	_escrever(_titulo, "VITÓRIA!" if eh_vitoria else "FIM DE JOGO", AREA_TITULO_RESULTADO, cor_do_titulo)
	_titulo.add_theme_font_size_override("font_size", 30)
	_escrever(_frase, frase, AREA_FRASE_RESULTADO, COR_TEXTO)
	_frase.add_theme_font_size_override("font_size", 17)
	_escrever(_pontos, "Pontos  %d" % pontos, AREA_PONTOS, COR_TEXTO)
	_escrever(_recorde, "Recorde  %d" % recorde, AREA_RECORDE, COR_TEXTO_SECUNDARIO)
	if eh_novo_recorde:
		_escrever(_novo_recorde, "NOVO RECORDE!", AREA_NOVO_RECORDE, COR_TITULO_VITORIA)
	_escrever(_instrucoes, "Enter: jogar de novo\nM: voltar ao menu", AREA_INSTRUCOES, COR_TEXTO_SECUNDARIO)


func esconder() -> void:
	visible = false


## Todo o texto que está aparecendo, em ordem (útil para testes e depuração).
func texto_visivel() -> String:
	var partes: Array[String] = []
	for rotulo: Label in [_titulo, _frase, _rodape, _pontos, _recorde, _novo_recorde, _instrucoes]:
		if rotulo.visible and not rotulo.text.is_empty():
			partes.append(rotulo.text)
	return "\n".join(partes)


func _preparar(moldura: Texture2D) -> void:
	_moldura.texture = moldura
	_moldura.visible = moldura != null
	for rotulo: Label in [_titulo, _frase, _rodape, _pontos, _recorde, _novo_recorde, _instrucoes]:
		rotulo.visible = false
		rotulo.text = ""
	_titulo.add_theme_font_size_override("font_size", 18)
	_frase.add_theme_font_size_override("font_size", 20)
	visible = true


func _escrever(rotulo: Label, texto: String, area: Rect2, cor: Color) -> void:
	# A largura vem antes do texto: com quebra de linha automática, um rótulo sem largura
	# calcula uma altura enorme e o texto acaba centralizado fora do quadro.
	rotulo.position = area.position
	rotulo.size = area.size
	rotulo.text = texto
	rotulo.size = area.size
	rotulo.add_theme_color_override("font_color", cor)
	rotulo.visible = true


func _criar_rotulo(tamanho_da_fonte: int, fonte: Font) -> Label:
	var rotulo := Label.new()
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rotulo.add_theme_font_size_override("font_size", tamanho_da_fonte)
	rotulo.add_theme_color_override("font_outline_color", COR_DO_CONTORNO)
	rotulo.add_theme_constant_override("outline_size", 4)
	if fonte != null:
		rotulo.add_theme_font_override("font", fonte)
	add_child(rotulo)
	return rotulo
