class_name IndicadorDeVidas
extends Node2D

## Mostra as vidas como ícones de nave no canto do HUD, alinhados à direita.
## Com mais vidas do que cabem, mostra um ícone e o número ("x 7").

const TAMANHO_DO_ICONE := Vector2(18, 18)
const ESPACO_ENTRE_ICONES := 4.0
const MAXIMO_DE_ICONES := 5
const TAMANHO_DA_FONTE := 16

## Ponto mais à direita onde os ícones terminam.
@export var borda_direita_x: float = 464.0
@export var icone: Texture2D

var _vidas: int = 0


func _ready() -> void:
	z_index = 60


func tem_icone() -> bool:
	return icone != null


func definir_vidas(vidas: int) -> void:
	_vidas = maxi(vidas, 0)
	queue_redraw()


func _draw() -> void:
	if icone == null or _vidas == 0:
		return
	if _vidas > MAXIMO_DE_ICONES:
		var texto := "x %d" % _vidas
		var fonte := _fonte_do_jogo()
		var largura_do_texto := fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANHO_DA_FONTE).x
		var x_do_texto := borda_direita_x - largura_do_texto
		draw_string(fonte, Vector2(x_do_texto, TAMANHO_DO_ICONE.y - 2), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANHO_DA_FONTE)
		draw_texture_rect(icone, Rect2(Vector2(x_do_texto - ESPACO_ENTRE_ICONES - TAMANHO_DO_ICONE.x, 0), TAMANHO_DO_ICONE), false)
		return
	for indice in _vidas:
		var x := borda_direita_x - (indice + 1) * TAMANHO_DO_ICONE.x - indice * ESPACO_ENTRE_ICONES
		draw_texture_rect(icone, Rect2(Vector2(x, 0), TAMANHO_DO_ICONE), false)


func _fonte_do_jogo() -> Font:
	var tema_do_projeto := ThemeDB.get_project_theme()
	if tema_do_projeto != null and tema_do_projeto.default_font != null:
		return tema_do_projeto.default_font
	return ThemeDB.fallback_font
