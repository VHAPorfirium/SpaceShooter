class_name Inimigo
extends Area2D

signal morreu(pontos: int, posicao: Vector2)
signal disparou(posicao: Vector2, direcao: Vector2)

const FORMAS := {
	DadosInimigo.Forma.TRIANGULO: [
		Vector2(0, 16), Vector2(15, -12), Vector2(-15, -12)],
	DadosInimigo.Forma.SETA: [
		Vector2(0, 14), Vector2(15, -12), Vector2(0, -4), Vector2(-15, -12)],
	DadosInimigo.Forma.BLOCO: [
		Vector2(-19, -14), Vector2(19, -14), Vector2(19, 12),
		Vector2(8, 12), Vector2(0, 22), Vector2(-8, 12), Vector2(-19, 12)],
	DadosInimigo.Forma.ROCHA: [
		Vector2(-6, -22), Vector2(12, -19), Vector2(22, -6), Vector2(19, 10),
		Vector2(8, 21), Vector2(-10, 20), Vector2(-21, 8), Vector2(-20, -10)],
}

const TAMANHO_BASE_DO_DESENHO_DA_ROCHA := Vector2(40, 40)

@export var dados: DadosInimigo

var fase: int = 1
var _vida: int
var _tempo: float = 0.0
var _tempo_tiro: float = 0.0
var _x_inicial: float
var _eh_rocha: bool = false


func _ready() -> void:
	if dados == null:
		push_error("Inimigo criado sem dados.")
		set_process(false)
		queue_free()
		return
	_vida = dados.vida
	_x_inicial = position.x
	_eh_rocha = dados.forma == DadosInimigo.Forma.ROCHA
	_configurar_tiro_inicial()
	$Desenho.polygon = PackedVector2Array(FORMAS[dados.forma])
	$Desenho.color = dados.cor
	if _eh_rocha:
		$Desenho.scale = dados.tamanho / TAMANHO_BASE_DO_DESENHO_DA_ROCHA  # plano B acompanha o tamanho
	$Imagem.exibir(dados.textura, dados.tamanho, [$Desenho])
	var forma_colisao := RectangleShape2D.new()
	forma_colisao.size = dados.tamanho
	$Forma.shape = forma_colisao
	$Notificador.screen_exited.connect(queue_free)
	area_entered.connect(_ao_receber_area)


func _configurar_tiro_inicial() -> void:
	# Inicializa com intervalo escalonado pela fase e um offset aleatório para não atirarem juntos
	match fase:
		1: _tempo_tiro = randf_range(2.0, 3.8)
		2: _tempo_tiro = randf_range(1.2, 2.4)
		_: _tempo_tiro = randf_range(0.8, 1.8)


func _process(delta: float) -> void:
	_tempo += delta
	var jogador := get_tree().get_first_node_in_group("jogador") as Node2D

	if _eh_rocha:
		# Asteroides continuam girando e caindo em rota de colisão
		position.y += dados.velocidade * delta
		if dados.velocidade_giro != 0.0:
			$Desenho.rotation += dados.velocidade_giro * delta
			$Imagem.rotation += dados.velocidade_giro * delta
		return

	# --- Movimentação e perseguição progressiva (drones) ---
	var fator_velocidade := 1.0 + float(fase - 1) * 0.15
	var vel_descida := dados.velocidade * fator_velocidade

	if is_instance_valid(jogador):
		var dx_jogador := jogador.global_position.x - position.x
		match fase:
			1:
				# Fase 1: movimento suave, desce reto com pouco desvio
				_x_inicial = move_toward(_x_inicial, jogador.global_position.x, 15.0 * delta)
			2:
				# Fase 2: move-se mais e converge suavemente na direção da nave
				_x_inicial = move_toward(_x_inicial, jogador.global_position.x, 50.0 * delta)
			_:
				# Fase 3+: persegue ativamente a coordenada X da nave e acelera se estiver acima dela
				_x_inicial = move_toward(_x_inicial, jogador.global_position.x, 90.0 * delta)
				if absf(dx_jogador) < 60.0 and position.y < jogador.global_position.y:
					vel_descida *= 1.35  # mergulho rápido em cima da nave

	position.y += vel_descida * delta

	if dados.movimento == DadosInimigo.Movimento.ZIGZAG:
		var amplitude_fase := dados.amplitude * (1.0 + float(fase - 1) * 0.2)
		position.x = _x_inicial + sin(_tempo * dados.frequencia) * amplitude_fase
	else:
		position.x = _x_inicial

	position.x = clampf(position.x, 20.0, 460.0)

	# --- Sistema de tiros progressivo ---
	_atualizar_tiro(delta, jogador)


func _atualizar_tiro(delta: float, jogador: Node2D) -> void:
	# Só atira quando estiver dentro da área visível da tela
	if position.y < 20.0 or position.y > 670.0:
		return

	_tempo_tiro -= delta
	if _tempo_tiro <= 0.0:
		var direcao_tiro := Vector2.DOWN
		if is_instance_valid(jogador):
			match fase:
				1:
					direcao_tiro = Vector2.DOWN
					_tempo_tiro = randf_range(3.2, 4.4)
				2:
					# Fase 2: tiro levemente inclinado em direção à nave
					var dir_mira := (jogador.global_position - global_position).normalized()
					direcao_tiro = Vector2.DOWN.slerp(dir_mira, 0.5)
					_tempo_tiro = randf_range(2.0, 2.8)
				_:
					# Fase 3: mira diretamente na nave do jogador
					direcao_tiro = (jogador.global_position - global_position).normalized()
					_tempo_tiro = randf_range(1.2, 1.8)
		else:
			_tempo_tiro = 2.5

		disparou.emit(global_position + Vector2(0, 20), direcao_tiro)



func _ao_receber_area(area: Area2D) -> void:
	area.queue_free()  # o tiro some ao acertar
	if _vida <= 0:
		return  # evita pontuar duas vezes se dois tiros chegarem juntos
	_vida -= 1
	if _vida > 0 and dados.textura_dano != null:
		$Imagem.trocar_textura(dados.textura_dano)  # mostra que já levou tiro
	if _vida <= 0:
		morreu.emit(dados.pontos, global_position)
		queue_free()
