class_name SpriteComPlanoB
extends Sprite2D

## Mostra a arte (textura) de um elemento do jogo no tamanho certo da tela.
## Se não houver textura, mantém visível o desenho geométrico antigo (o "plano B"),
## então o jogo nunca fica sem visual enquanto a arte não chega.

var _tamanho_na_tela: Vector2 = Vector2.ZERO
var _nos_do_plano_b: Array[CanvasItem] = []


## Configura o visual. tamanho_na_tela é o tamanho que a arte deve ocupar,
## igual ao da área de colisão, qualquer que seja a escala de importação do SVG.
func exibir(nova_textura: Texture2D, tamanho_na_tela: Vector2, nos_do_plano_b: Array) -> void:
	_tamanho_na_tela = tamanho_na_tela
	_nos_do_plano_b.assign(nos_do_plano_b)
	trocar_textura(nova_textura)


## Troca só a imagem (aviso do chefe, Bastião danificado, etapa da Colmeia...)
## mantendo o mesmo tamanho na tela.
func trocar_textura(nova_textura: Texture2D) -> void:
	texture = nova_textura
	var tem_textura := nova_textura != null
	visible = tem_textura
	if tem_textura:
		scale = _tamanho_na_tela / nova_textura.get_size()
	for no in _nos_do_plano_b:
		no.visible = not tem_textura


func usa_textura() -> bool:
	return texture != null
