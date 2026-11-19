extends Node2D

enum Estado { JOGANDO, TRANSICAO, FIM, VITORIA }

const ATRASO_PARA_ACEITAR_REINICIO_SEGUNDOS := 0.7
const DURACAO_DA_FRASE_INICIAL_SEGUNDOS := 3.0
const FRASE_DA_VITORIA := "A Colmeia caiu. A Terra está a salvo."
const FRASE_DO_FIM_DE_JOGO := "A frota invasora segue rumo à Terra."
const COR_CONTORNO_DO_HUD := Color("#0a0818")
const COR_EXPLOSAO_DO_CHEFE := Color("#ff9f45")
const COR_EXPLOSAO_DO_JOGADOR := Color("#5ee7ff")
const RAIO_A_PARTIR_DO_QUAL_A_EXPLOSAO_E_GRANDE := 60.0
const TAMANHO_DA_FAISCA_DE_ACERTO := Vector2(20, 20)
const DURACAO_DA_FAISCA_DE_ACERTO := 0.15

@export var cena_tiro: PackedScene
@export var cena_tiro_inimigo: PackedScene
@export var cena_inimigo: PackedScene
@export var cena_item: PackedScene
@export var chance_drop: float = 0.05
@export_group("Efeitos animados (vazio = efeito desenhado em código)")
@export var quadros_explosao_pequena: SpriteFrames
@export var quadros_explosao_grande: SpriteFrames
@export var quadros_acerto: SpriteFrames
@export_group("")

var _fases: Array[DadosFase] = []
var _fase_atual: int = 0
var _estado: Estado = Estado.JOGANDO
var _ondas_acabaram: bool = false
var _chefe_ativo: bool = false
var _pontos: int = 0
var _recorde: int = 0
var _nome_do_chefe_atual: String = ""
var _aceita_reinicio: bool = false
var _chefe_atual: ChefeBase

@onready var _jogador: Area2D = $Jogador
@onready var _tiros: Node2D = $Tiros
@onready var _tiros_inimigos: Node2D = $TirosInimigos
@onready var _inimigos: Node2D = $Inimigos
@onready var _itens: Node2D = $Itens
@onready var _gerenciador: GerenciadorFase = $Fase
@onready var _tempo_transicao: Timer = $TempoTransicao
@onready var _placar: Label = $Placar
@onready var _recorde_label: Label = $RecordeLabel
@onready var _vidas_label: Label = $Vidas
@onready var _poder_label: Label = $PoderLabel
@onready var _fase_label: Label = $FaseLabel
@onready var _painel_de_mensagem: PainelDeMensagem = $PainelDeMensagem
@onready var _barra_chefe: TextureProgressBar = $BarraChefe
@onready var _indicador_de_vidas: IndicadorDeVidas = $IndicadorDeVidas
@onready var _fundo_estrelado: FundoEstrelado = $FundoEstrelado
@onready var _cenario: CenarioRolante = $Cenario
@onready var _efeitos: Node2D = $Efeitos
@onready var _flash_de_dano: FlashDeDano = $FlashDeDano


func _ready() -> void:
	_jogador.disparou.connect(_ao_jogador_disparar)
	_jogador.vidas_mudaram.connect(_ao_jogador_perder_vida)
	_jogador.poder_coletado.connect(_ao_jogador_coletar_poder)
	_jogador.poderes_mudaram.connect(_ao_poderes_mudarem)
	_jogador.destruida.connect(_ao_jogador_destruido)
	_gerenciador.spawn_solicitado.connect(_ao_spawn_solicitado)
	_gerenciador.roteiro_concluido.connect(_ao_ondas_esgotadas)
	_tempo_transicao.timeout.connect(_ao_fim_transicao)

	_configurar_hud()
	_recorde = Recorde.carregar()
	_recorde_label.text = "Recorde %d" % _recorde
	_atualizar_placar()
	_ao_vidas_mudarem(_jogador.vidas)

	_fases.append(CatalogoFases.fase_1())
	_fases.append(CatalogoFases.fase_2())
	_fases.append(CatalogoFases.fase_3())
	_iniciar_fase(0)
	_mostrar_frase_inicial()


## Organiza o HUD em faixas para nada ficar por cima de nada:
## linha 1: Pontos (esquerda) e Vidas (direita); linha 2: Recorde;
## linha 3: nome da fase/chefe no centro; linha 4: barra do chefe;
## rodapé: poderes ativos.
func _configurar_hud() -> void:
	_posicionar_rotulo(_placar, Vector2(16, 6), Vector2(180, 20), HORIZONTAL_ALIGNMENT_LEFT, 16)
	_posicionar_rotulo(_vidas_label, Vector2(250, 6), Vector2(214, 20), HORIZONTAL_ALIGNMENT_RIGHT, 16)
	_posicionar_rotulo(_recorde_label, Vector2(16, 26), Vector2(180, 18), HORIZONTAL_ALIGNMENT_LEFT, 13)
	_posicionar_rotulo(_fase_label, Vector2(0, 22), Vector2(480, 20), HORIZONTAL_ALIGNMENT_CENTER, 15)
	_posicionar_rotulo(_poder_label, Vector2(16, 692), Vector2(448, 20), HORIZONTAL_ALIGNMENT_LEFT, 14)
	_poder_label.text = ""

	_barra_chefe.position = Vector2(120, 46)
	_barra_chefe.size = Vector2(240, 8)
	_barra_chefe.nine_patch_stretch = true  # estica a arte da barra para o tamanho acima
	_barra_chefe.z_index = 60
	_barra_chefe.visible = false

	_indicador_de_vidas.position = Vector2(0, 6)
	_vidas_label.visible = not _indicador_de_vidas.tem_icone()  # plano B: "Vidas 3" em texto

	_flash_de_dano.position = Vector2.ZERO
	_flash_de_dano.size = FundoEstrelado.TAMANHO_DA_TELA


func _posicionar_rotulo(rotulo: Label, posicao: Vector2, tamanho: Vector2,
		alinhamento: HorizontalAlignment, tamanho_da_fonte: int) -> void:
	rotulo.position = posicao
	rotulo.size = tamanho
	rotulo.horizontal_alignment = alinhamento
	rotulo.z_index = 60  # HUD acima de tudo, inclusive do piscar de dano
	rotulo.add_theme_font_size_override("font_size", tamanho_da_fonte)
	rotulo.add_theme_color_override("font_outline_color", COR_CONTORNO_DO_HUD)
	rotulo.add_theme_constant_override("outline_size", 4)


func _mostrar_frase_inicial() -> void:
	var primeira_fase := _fases[0]
	_painel_de_mensagem.mostrar_abertura_de_fase(primeira_fase.nome, primeira_fase.frase_de_abertura)
	await get_tree().create_timer(DURACAO_DA_FRASE_INICIAL_SEGUNDOS).timeout
	if _estado == Estado.JOGANDO and _fase_atual == 0:
		_painel_de_mensagem.esconder()


func _atualizar_placar() -> void:
	_placar.text = "Pontos %d" % _pontos


func _process(_delta: float) -> void:
	if _estado != Estado.JOGANDO or not _ondas_acabaram or _chefe_ativo:
		return
	if _inimigos.get_child_count() > 0:
		return
	var fase := _fases[_fase_atual]
	if fase.chefe != null:
		_iniciar_chefe(fase)
	else:
		_concluir_fase()


func _unhandled_input(event: InputEvent) -> void:
	var terminou := _estado == Estado.FIM or _estado == Estado.VITORIA
	if not terminou or not _aceita_reinicio:
		return  # espera um instante para o tiro (Espaço) não reiniciar sem querer
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	else:
		var tecla := event as InputEventKey
		if tecla != null and tecla.pressed and not tecla.echo and tecla.keycode == KEY_M:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _iniciar_fase(indice: int) -> void:
	_fase_atual = indice
	_ondas_acabaram = false
	_chefe_ativo = false
	_estado = Estado.JOGANDO
	var fase := _fases[indice]
	RenderingServer.set_default_clear_color(fase.cor_fundo)
	_fundo_estrelado.definir_cor_das_estrelas(fase.cor_estrelas)
	_cenario.definir_camadas(fase.camadas_do_cenario)
	_fundo_estrelado.visible = not _cenario.tem_camadas()  # plano B: estrelas em código
	_fase_label.text = fase.nome
	_barra_chefe.visible = false
	_painel_de_mensagem.esconder()
	_gerenciador.iniciar(fase)
	GerenciadorAudio.tocar_musica(fase.musica)


func _iniciar_chefe(fase: DadosFase) -> void:
	_chefe_ativo = true
	var chefe: ChefeBase = fase.chefe.instantiate()
	chefe.position = Vector2(240.0, -70.0)
	chefe.vida_mudou.connect(_ao_vida_chefe_mudou)
	chefe.derrotado.connect(_ao_chefe_derrotado)
	chefe.disparou.connect(_ao_chefe_disparar)
	chefe.aviso_iniciado.connect(_ao_chefe_iniciar_aviso)
	chefe.etapa_mudou.connect(_ao_chefe_mudar_etapa)
	chefe.invocacao_solicitada.connect(_ao_spawn_solicitado)
	chefe.atingido.connect(_ao_chefe_ser_atingido)
	_chefe_atual = chefe
	_inimigos.add_child(chefe)
	_fase_label.text = _texto_do_chefe(chefe.nome, chefe.etapa_atual, chefe.total_de_etapas())
	_nome_do_chefe_atual = chefe.nome
	if fase.musica_chefe != null:
		GerenciadorAudio.tocar_musica(fase.musica_chefe)


func _concluir_fase() -> void:
	for tiro in _tiros_inimigos.get_children():
		tiro.queue_free()
	if _fase_atual + 1 < _fases.size():
		_estado = Estado.TRANSICAO
		var proxima_fase := _fases[_fase_atual + 1]
		_painel_de_mensagem.mostrar_transicao(_fases[_fase_atual].nome, proxima_fase.frase_de_abertura, proxima_fase.nome)
		_tempo_transicao.start()
		GerenciadorAudio.tocar_encerramento(GerenciadorAudio.Efeito.FASE_CONCLUIDA)
	else:
		_estado = Estado.VITORIA
		_finalizar_partida(true)


func _ao_fim_transicao() -> void:
	if _estado == Estado.TRANSICAO:
		_iniciar_fase(_fase_atual + 1)


func _ao_ondas_esgotadas() -> void:
	_ondas_acabaram = true


func _ao_spawn_solicitado(dados: DadosInimigo, posicao: Vector2) -> void:
	var inimigo: Inimigo = cena_inimigo.instantiate()
	inimigo.dados = dados
	inimigo.fase = _fase_atual + 1
	inimigo.position = posicao
	inimigo.morreu.connect(_ao_inimigo_morrer.bind(dados.cor))
	inimigo.disparou.connect(_ao_inimigo_disparar)
	_inimigos.add_child(inimigo)


func _ao_jogador_disparar(posicao: Vector2, direcao: Vector2) -> void:
	var tiro: Tiro = cena_tiro.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros.add_child(tiro)
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.TIRO_JOGADOR)


func _ao_inimigo_disparar(posicao: Vector2, direcao: Vector2 = Vector2.DOWN) -> void:
	var tiro: TiroInimigo = cena_tiro_inimigo.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros_inimigos.add_child(tiro)
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.TIRO_INIMIGO)


func _ao_chefe_disparar(posicao: Vector2, direcao: Vector2) -> void:
	var tiro: TiroInimigo = cena_tiro_inimigo.instantiate()
	tiro.position = posicao
	tiro.direcao = direcao
	_tiros_inimigos.add_child(tiro)
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.TIRO_INIMIGO)


func _ao_vida_chefe_mudou(vida: int, vida_maxima: int) -> void:
	_barra_chefe.max_value = vida_maxima
	_barra_chefe.value = vida
	_barra_chefe.visible = true
	_pintar_barra_do_chefe()
	var chefe_foi_atingido := vida < vida_maxima
	if chefe_foi_atingido:
		GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.ACERTO_CHEFE)


func _ao_chefe_derrotado(pontos: int, posicao: Vector2) -> void:
	_pontos += pontos
	_atualizar_placar()
	_criar_explosao(posicao, COR_EXPLOSAO_DO_CHEFE, 90.0, 1.0)
	_chefe_ativo = false
	_barra_chefe.visible = false
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.EXPLOSAO_CHEFE)
	_concluir_fase()


func _ao_inimigo_morrer(pontos: int, posicao: Vector2, cor_do_inimigo: Color) -> void:
	_pontos += pontos
	_atualizar_placar()
	_criar_explosao.call_deferred(posicao, cor_do_inimigo, 26.0, 0.45)
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.EXPLOSAO_INIMIGO)
	# Adiado: criar uma Area2D no meio de um callback de física causa erro
	_tentar_dropar.call_deferred(posicao)


func _tentar_dropar(posicao: Vector2) -> void:
	var poderes_da_fase := _fases[_fase_atual].poderes
	if poderes_da_fase.is_empty() or cena_item == null:
		return
	# Se já tem 2 ou mais poderes caídos na tela, não dropa mais
	if _itens.get_child_count() >= 2:
		return
	if randf() > chance_drop:
		return
	var item: ItemPoder = cena_item.instantiate()
	item.dados = poderes_da_fase.pick_random()
	item.position = posicao
	_itens.add_child(item)


func _ao_vidas_mudarem(vidas: int) -> void:
	_vidas_label.text = "Vidas %d" % vidas
	_indicador_de_vidas.definir_vidas(vidas)


## Explosão animada com a arte; sem a arte, a explosão desenhada em código (plano B).
func _criar_explosao(posicao: Vector2, cor: Color, raio: float, duracao: float) -> void:
	var explosao_e_grande := raio >= RAIO_A_PARTIR_DO_QUAL_A_EXPLOSAO_E_GRANDE
	var quadros := quadros_explosao_grande if explosao_e_grande else quadros_explosao_pequena
	if quadros == null:
		_efeitos.add_child(Explosao.criar(posicao, cor, raio, duracao))
		return
	_efeitos.add_child(EfeitoAnimado.criar(posicao, quadros, Vector2.ONE * raio * 2.0, duracao))


func _ao_chefe_ser_atingido(posicao_do_impacto: Vector2) -> void:
	if quadros_acerto == null:
		return
	_criar_faisca_de_acerto.call_deferred(posicao_do_impacto)


func _criar_faisca_de_acerto(posicao: Vector2) -> void:
	_efeitos.add_child(EfeitoAnimado.criar(posicao, quadros_acerto, TAMANHO_DA_FAISCA_DE_ACERTO, DURACAO_DA_FAISCA_DE_ACERTO))


func _ao_jogador_perder_vida(vidas: int) -> void:
	_ao_vidas_mudarem(vidas)
	_flash_de_dano.piscar()
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.DANO_JOGADOR)


func _ao_jogador_coletar_poder(_poder: DadosPoder) -> void:
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.PODER_COLETADO)


func _ao_chefe_mudar_etapa(etapa_atual: int, total_de_etapas: int) -> void:
	_fase_label.text = _texto_do_chefe(_nome_do_chefe_atual, etapa_atual, total_de_etapas)
	_pintar_barra_do_chefe()


## A barra de vida usa a cor do chefe (e da etapa, na Colmeia).
func _pintar_barra_do_chefe() -> void:
	if is_instance_valid(_chefe_atual):
		_barra_chefe.tint_progress = _chefe_atual.cor_da_barra_de_vida()


func _texto_do_chefe(nome_do_chefe: String, etapa_atual: int, total_de_etapas: int) -> String:
	if total_de_etapas <= 1:
		return "Chefe: %s" % nome_do_chefe
	return "Chefe: %s (etapa %d/%d)" % [nome_do_chefe, etapa_atual, total_de_etapas]


func _ao_chefe_iniciar_aviso() -> void:
	GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.AVISO_CHEFE)


func _ao_poderes_mudarem(texto: String) -> void:
	_poder_label.text = texto


func _ao_jogador_destruido() -> void:
	if _estado == Estado.VITORIA:
		return  # um Batedor que sobrou não pode transformar a vitória em derrota
	_estado = Estado.FIM
	_tempo_transicao.stop()
	_criar_explosao.call_deferred(_jogador.global_position, COR_EXPLOSAO_DO_JOGADOR, 60.0, 0.8)
	_finalizar_partida(false)


func _finalizar_partida(eh_vitoria: bool) -> void:
	$Pausa.habilitada = false
	GerenciadorAudio.tocar_encerramento(GerenciadorAudio.Efeito.VITORIA if eh_vitoria else GerenciadorAudio.Efeito.FIM_DE_JOGO)
	_gerenciador.parar()
	_barra_chefe.visible = false

	var novo_recorde := _pontos > _recorde
	if novo_recorde:
		_recorde = _pontos
		Recorde.salvar(_recorde)
		_recorde_label.text = "Recorde %d" % _recorde

	var frase := FRASE_DA_VITORIA if eh_vitoria else FRASE_DO_FIM_DE_JOGO
	_painel_de_mensagem.mostrar_resultado(eh_vitoria, frase, _pontos, _recorde, novo_recorde)
	_aceita_reinicio = false
	await get_tree().create_timer(ATRASO_PARA_ACEITAR_REINICIO_SEGUNDOS).timeout
	_aceita_reinicio = true
