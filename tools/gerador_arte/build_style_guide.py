"""Gera a prancha de guia de estilo (project/Main.dc.html) a partir da biblioteca de sprites."""
import random
import sys
from pathlib import Path

import sprites as sp

BOARD_WIDTH = 1720
BOARD_HEIGHT = 3860
LINEUP_SCALE = 3
BOARD_BACKGROUND = "#0b0a1a"
TEXT_COLOR = "#ece9ff"
MUTED_TEXT_COLOR = "#a6a1c7"
HAIRLINE_COLOR = "#26224a"
TITLE_FONT = "'Orbitron', 'Segoe UI', sans-serif"
BODY_FONT = "'Chakra Petch', 'Segoe UI', sans-serif"


# ---------- cenas de fase (480 x 720) ----------

def scattered_stars(random_generator, amount, radius_range, color, opacity_range, area=(0, 0, 480, 720)):
    left, top, right, bottom = area
    stars = []
    for _ in range(amount):
        stars.append(sp.circle(round(random_generator.uniform(left, right), 1), round(random_generator.uniform(top, bottom), 1),
                               round(random_generator.uniform(*radius_range), 2), fill=color,
                               opacity=round(random_generator.uniform(*opacity_range), 2)))
    return "".join(stars)


def heads_up_display(phase_label, score_text, boss=None):
    parts = [
        sp.rectangle(0, 0, 480, 46, fill="#000000", opacity="0.35"),
        sp.line(0, 46, 480, 46, stroke="#ffffff", stroke_opacity="0.08"),
        f'<text x="16" y="17" font-family="{BODY_FONT}" font-size="11" font-weight="600" letter-spacing="1.5" fill="#c4bfe3">PONTOS</text>',
        f'<text x="16" y="38" font-family="{TITLE_FONT}" font-size="20" font-weight="700" fill="#ffffff">{score_text}</text>',
        f'<text x="240" y="28" text-anchor="middle" font-family="{TITLE_FONT}" font-size="12" font-weight="600" letter-spacing="2" fill="#ffffff" opacity="0.85">{phase_label}</text>',
    ]
    parts += [sp.placed_svg(sp.life_icon(), center_x, 24) for center_x in (412, 432, 452)]
    if boss:
        boss_name, boss_color, health_fraction = boss
        parts += [
            f'<text x="240" y="64" text-anchor="middle" font-family="{TITLE_FONT}" font-size="11" font-weight="700" letter-spacing="2.5" fill="#ffffff">{boss_name}</text>',
            sp.rectangle(90, 70, 300, 12, rx="6", fill="#1a1030", stroke="#ffffff", stroke_opacity="0.55"),
            sp.rectangle(92, 72, round(296 * health_fraction, 1), 8, rx="4", fill=boss_color),
        ]
    return "".join(parts)


def player_shot_pair(center_x, center_y, spacing=14):
    shot = sp.player_shot()
    return sp.placed_svg(shot, center_x - spacing / 2, center_y) + sp.placed_svg(shot, center_x + spacing / 2, center_y)


def player_triple_shot(center_x, center_y):
    shot = sp.player_shot()
    return (sp.placed_svg(shot, center_x - 14, center_y + 4, -12) + sp.placed_svg(shot, center_x, center_y)
            + sp.placed_svg(shot, center_x + 14, center_y + 4, 12))


def player_with_engine(center_x, center_y, frame_number=1):
    return sp.placed_svg(sp.player_engine_flame(frame_number), center_x, center_y + 21.5) + sp.placed_svg(sp.player_ship(), center_x, center_y)


def enemy_shots(positions):
    shot = sp.enemy_shot()
    return "".join(sp.placed_svg(shot, x, y) for x, y in positions)


def phase_one_scene():
    random_generator = random.Random(11)
    parts = [
        sp.rectangle(0, 0, 480, 720, fill="#0d1b3a"),
        scattered_stars(random_generator, 70, (0.5, 0.9), "#9fb3d9", (0.3, 0.6)),
        sp.circle(-70, 840, 330, fill="#143064"),
        sp.path("M-40,560 Q60,540 150,600 Q100,610 40,590 Q0,585 -40,600 Z", fill="#1d4282", opacity="0.6"),
        sp.path("M60,650 Q140,630 220,680 Q160,690 100,672 Z", fill="#1d4282", opacity="0.5"),
        sp.circle(-70, 840, 336, fill="none", stroke="#2d63b8", stroke_width="7", stroke_opacity="0.35"),
        scattered_stars(random_generator, 22, (1.1, 1.6), "#cfdaf0", (0.45, 0.7), area=(0, 50, 480, 520)),
        sp.placed_svg(sp.scout_drone(), 240, 150),
        sp.placed_svg(sp.scout_drone(), 200, 118),
        sp.placed_svg(sp.scout_drone(), 280, 118),
        sp.placed_svg(sp.serpent_drone(), 110, 290),
        sp.placed_svg(sp.serpent_drone(), 385, 335),
        sp.placed_svg(sp.bastion_drone(), 330, 220),
        enemy_shots([(326, 262), (312, 318), (298, 374), (110, 330), (122, 386)]),
        sp.placed_svg(sp.power_up_double_shot(), 160, 430),
        player_shot_pair(240, 560), player_shot_pair(240, 500), player_shot_pair(240, 440),
        player_with_engine(240, 610),
        heads_up_display("FASE 1", "012 450"),
    ]
    return "".join(parts)


def decorative_rock(points, offset_x, offset_y, scale):
    transformed = [(offset_x + x * scale, offset_y + y * scale) for x, y in points]
    return sp.polygon(transformed, fill="#1c120c", stroke="#3b281c", stroke_width="2", stroke_linejoin="round")


def phase_two_scene():
    random_generator = random.Random(22)
    rock_shape = [(0, 20), (18, 0), (46, 4), (64, 26), (58, 52), (30, 64), (6, 50)]
    parts = [
        sp.rectangle(0, 0, 480, 720, fill="#2a1a12"),
        sp.ellipse(130, 220, 220, 70, fill="#3a2418", opacity="0.55", transform="rotate(-18 130 220)"),
        sp.ellipse(380, 520, 240, 80, fill="#3a2418", opacity="0.45", transform="rotate(-24 380 520)"),
        scattered_stars(random_generator, 55, (0.5, 0.9), "#c9a98a", (0.25, 0.5)),
        decorative_rock(rock_shape, -30, 380, 1.6),
        decorative_rock(rock_shape, 410, 120, 1.3),
        decorative_rock(rock_shape, 420, 600, 2.0),
        sp.placed_svg(sp.reaper_boss(), 240, 140),
        enemy_shots([(204, 222), (240, 232), (276, 222), (172, 280), (240, 300), (308, 280)]),
        sp.placed_svg(sp.hazard_asteroid(1), 92, 300),
        sp.placed_svg(sp.hazard_asteroid(2), 395, 410),
        sp.placed_svg(sp.hazard_asteroid(3), 80, 520),
        sp.placed_svg(sp.power_up_triple_shot(), 330, 470),
        player_triple_shot(240, 530),
        sp.placed_svg(sp.player_shot(), 202, 556),
        sp.placed_svg(sp.helper_ship(), 202, 618),
        player_with_engine(240, 610, 2),
        sp.placed_svg(sp.player_shield(), 240, 612),
        heads_up_display("FASE 2", "034 900", boss=("CEIFADOR", "#e056fd", 0.72)),
    ]
    return "".join(parts)


def phase_three_scene():
    random_generator = random.Random(33)
    parts = [
        sp.rectangle(0, 0, 480, 720, fill="#2b0d24"),
        scattered_stars(random_generator, 40, (0.5, 0.9), "#d9a5c9", (0.2, 0.4), area=(70, 0, 410, 720)),
        sp.rectangle(0, 0, 58, 720, fill="#34112d"),
        sp.rectangle(422, 0, 58, 720, fill="#34112d"),
    ]
    for panel_top in range(20, 720, 90):
        parts += [sp.rectangle(8, panel_top, 42, 72, rx="3", fill="none", stroke="#45183c", stroke_width="2"),
                  sp.rectangle(430, panel_top, 42, 72, rx="3", fill="none", stroke="#45183c", stroke_width="2")]
    for beam_top in (250, 520):
        parts.append(sp.rectangle(58, beam_top, 364, 10, fill="#3a1331"))
        parts += [sp.circle(light_x, beam_top + 5, 1.8, fill="#ff3b3b", opacity="0.55") for light_x in range(80, 420, 40)]
    parts += [
        sp.placed_svg(sp.hive_boss(2), 240, 130),
        sp.placed_svg(sp.scout_drone(), 196, 214),
        sp.placed_svg(sp.scout_drone(), 286, 204),
        sp.placed_svg(sp.scout_drone(), 150, 286),
        sp.placed_svg(sp.serpent_drone(), 345, 320),
        enemy_shots([(240, 196), (226, 250), (254, 250), (205, 330), (275, 330), (345, 360)]),
        sp.placed_svg(sp.power_up_shield(), 380, 455),
        sp.placed_svg(sp.power_up_helper(), 110, 470),
        player_triple_shot(250, 540),
        player_with_engine(250, 612, 3),
        heads_up_display("FASE 3", "071 300", boss=("COLMEIA", "#d63384", 0.55)),
    ]
    return "".join(parts)


def phase_screen_svg(scene_markup, label):
    return (f'<svg width="480" height="720" viewBox="0 0 480 720" role="img" aria-label="{label}" '
            f'style="display: block; border-radius: 4px; outline: 1px solid {HAIRLINE_COLOR}">'
            f'<defs><clipPath id="screen-{label.split()[1]}"><rect width="480" height="720"/></clipPath></defs>'
            f'<g clip-path="url(#screen-{label.split()[1]})">{scene_markup}</g></svg>')


# ---------- blocos de HTML ----------

def section_heading(number, title, description):
    return (f'<div style="display: flex; align-items: baseline; gap: 20px; border-bottom: 1px solid {HAIRLINE_COLOR}; padding-bottom: 14px">'
            f'<span style="font-family: {TITLE_FONT}; font-size: 14px; color: {MUTED_TEXT_COLOR}; letter-spacing: 2px">{number:02d}</span>'
            f'<h2 style="margin: 0; font-family: {TITLE_FONT}; font-size: 26px; font-weight: 700; letter-spacing: 1px">{title}</h2>'
            f'<p style="margin: 0; font-size: 15px; color: {MUTED_TEXT_COLOR}">{description}</p></div>')


def swatch_card(name, hex_code, support_tones):
    chips = "".join(f'<div title="{tone}" style="flex: 1; height: 16px; background: {tone}"></div>' for tone in support_tones)
    return (f'<div style="width: 160px; display: flex; flex-direction: column; gap: 6px">'
            f'<div style="height: 64px; background: {hex_code}; border-radius: 4px 4px 0 0; outline: 1px solid rgba(255,255,255,0.08)"></div>'
            f'<div style="display: flex; margin-top: -6px; border-radius: 0 0 4px 4px; overflow: hidden">{chips}</div>'
            f'<div style="font-size: 14px; font-weight: 600">{name}</div>'
            f'<div style="font-family: ui-monospace, Menlo, monospace; font-size: 13px; color: {MUTED_TEXT_COLOR}">{hex_code}</div>'
            f'<div style="font-family: ui-monospace, Menlo, monospace; font-size: 11px; color: {MUTED_TEXT_COLOR}">{" · ".join(support_tones)}</div></div>')


def palette_row(group_label, swatches):
    cards = "".join(swatch_card(*swatch) for swatch in swatches)
    return (f'<div style="display: flex; gap: 16px">'
            f'<div style="width: 160px; flex-shrink: 0; font-family: {TITLE_FONT}; font-size: 13px; letter-spacing: 1.5px; color: {MUTED_TEXT_COLOR}; padding-top: 4px">{group_label}</div>'
            f'<div style="display: flex; gap: 14px; flex-wrap: wrap">{cards}</div></div>')


def palette_section():
    def tones(palette):
        return [palette.shade, palette.light, palette.outline]
    rows = [
        palette_row("FUNDOS", [
            ("Menu", "#14102b", ["#241d4a", "#3a3170", "#8b84c7"]),
            ("Fase 1 · Órbita", "#0d1b3a", ["#143064", "#2d63b8", "#9fb3d9"]),
            ("Fase 2 · Cinturão", "#2a1a12", ["#3a2418", "#1c120c", "#c9a98a"]),
            ("Fase 3 · Nave-Mãe", "#2b0d24", ["#34112d", "#45183c", "#ff3b3b"]),
        ]),
        palette_row("JOGADOR E TIROS", [
            ("Jogador", "#5ee7ff", tones(sp.PLAYER_PALETTE)),
            ("Nave de ajuda", "#ff8fd1", tones(sp.HELPER_PALETTE)),
            ("Tiro do jogador", "#ffd166", ["#fff6d6", "#ffd166", "#e0a93a"]),
            ("Tiro inimigo", "#ffffff", ["#ffffff", "#ff5d73", "#ffe0e5"]),
        ]),
        palette_row("INIMIGOS E CHEFES", [
            ("Batedor", "#ff5d73", tones(sp.SCOUT_PALETTE)),
            ("Serpente", "#c77dff", tones(sp.SERPENT_PALETTE)),
            ("Bastião", "#ff9f45", [sp.BASTION_PALETTE.shade, sp.BASTION_PALETTE.plate, sp.BASTION_PALETTE.outline]),
            ("Sentinela-01", "#ff5d73", tones(sp.SENTINEL_PALETTE)),
            ("Ceifador", "#e056fd", tones(sp.REAPER_PALETTE)),
            ("Colmeia · etapa 1", "#9b5de5", tones(sp.HIVE_STAGE_ONE_PALETTE)),
            ("Colmeia · etapa 2", "#d63384", tones(sp.HIVE_STAGE_TWO_PALETTE)),
            ("Colmeia · etapa 3", "#ff3b3b", tones(sp.HIVE_STAGE_THREE_PALETTE)),
        ]),
        palette_row("PODERES", [
            ("Tiro duplo", "#7bd88f", ["#10101e", "#7bd88f", "#7bd88f"]),
            ("Tiro triplo", "#ffd166", ["#10101e", "#ffd166", "#ffd166"]),
            ("Escudo", "#5ee7ff", ["#10101e", "#5ee7ff", "#5ee7ff"]),
            ("Nave de ajuda", "#ff8fd1", ["#10101e", "#ff8fd1", "#ff8fd1"]),
        ]),
    ]
    note = (f'<p style="margin: 0; font-size: 13px; color: {MUTED_TEXT_COLOR}">Faixa abaixo de cada cor: sombra · luz · contorno '
            f'(nos fundos: tons de apoio usados em estrelas, planeta, poeira e estruturas). Motores inimigos usam #ffb347.</p>')
    return f'<section style="display: flex; flex-direction: column; gap: 24px">{section_heading(1, "Paleta", "cores-base do briefing + tons de apoio derivados")}{note}{"".join(rows)}</section>'


def lineup_item(svg_markup, file_name, size_text):
    return (f'<div style="display: flex; flex-direction: column; align-items: center; gap: 10px">{svg_markup}'
            f'<div style="display: flex; flex-direction: column; align-items: center; gap: 2px">'
            f'<div style="font-size: 14px; font-weight: 600">{file_name}</div>'
            f'<div style="font-family: ui-monospace, Menlo, monospace; font-size: 12px; color: {MUTED_TEXT_COLOR}">{size_text}</div></div></div>')


def sprite_item(sprite, scale=LINEUP_SCALE, file_name=None):
    return lineup_item(sp.inline_svg(sprite, scale, label=sprite.name), file_name or f"{sprite.name}.svg",
                       f"{sprite.width:g} × {sprite.height:g}")


def player_with_engine_item():
    composite = sp.Sprite("jogador com motor", 30, 46,
                          sp.placed_svg(sp.player_engine_flame(1), 15, 38.5) + sp.placed_svg(sp.player_ship(), 15, 17))
    return lineup_item(sp.inline_svg(composite, LINEUP_SCALE, label="jogador com motor"), "jogador.svg + motor_01", "30 × 34 · 10 × 12")


def player_with_shield_item():
    composite = sp.Sprite("jogador com escudo", 56, 56,
                          sp.placed_svg(sp.player_ship(), 28, 28) + sp.placed_svg(sp.player_shield(), 28, 28))
    return lineup_item(sp.inline_svg(composite, LINEUP_SCALE, label="jogador com escudo"), "jogador_escudo.svg", "56 × 56")


def lineup_row(items, caption):
    return (f'<div style="display: flex; flex-direction: column; gap: 18px">'
            f'<div style="font-family: {TITLE_FONT}; font-size: 13px; letter-spacing: 1.5px; color: {MUTED_TEXT_COLOR}">{caption}</div>'
            f'<div style="display: flex; align-items: flex-end; gap: 48px; flex-wrap: wrap">{"".join(items)}</div></div>')


def actual_size_strip():
    sprite_list = [sp.player_ship(), sp.helper_ship(), sp.scout_drone(), sp.serpent_drone(), sp.bastion_drone(),
                   sp.sentinel_boss(), sp.reaper_boss(), sp.hive_boss(1), sp.hive_boss(2), sp.hive_boss(3),
                   sp.player_shot(), sp.enemy_shot(), sp.power_up_double_shot(), sp.power_up_triple_shot(),
                   sp.power_up_shield(), sp.power_up_helper()]
    sprites_markup = "".join(sp.inline_svg(sprite, 1, label=sprite.name) for sprite in sprite_list)
    return (f'<div style="display: flex; align-items: center; gap: 28px; padding: 20px 24px; background: #0d1b3a; border-radius: 6px">'
            f'<div style="font-family: {TITLE_FONT}; font-size: 13px; letter-spacing: 1.5px; color: #c4cde6; width: 120px; flex-shrink: 0">TAMANHO REAL 1×</div>'
            f'{sprites_markup}</div>')


def lineup_section():
    rows = [
        lineup_row([player_with_engine_item(), player_with_shield_item(), sprite_item(sp.helper_ship()),
                    sprite_item(sp.scout_drone()), sprite_item(sp.serpent_drone()), sprite_item(sp.bastion_drone()),
                    sprite_item(sp.bastion_drone_damaged())], "JOGADOR, ALIADO E INIMIGOS COMUNS · 3×"),
        lineup_row([sprite_item(sp.player_shot()), sprite_item(sp.enemy_shot()), sprite_item(sp.power_up_double_shot()),
                    sprite_item(sp.power_up_triple_shot()), sprite_item(sp.power_up_shield()), sprite_item(sp.power_up_helper()),
                    sprite_item(sp.hazard_asteroid(1)), sprite_item(sp.hazard_asteroid(2)), sprite_item(sp.hazard_asteroid(3))],
                   "TIROS, PODERES E ASTEROIDES · 3×"),
        lineup_row([sprite_item(sp.sentinel_boss()), sprite_item(sp.reaper_boss()), sprite_item(sp.hive_boss(1))],
                   "CHEFES · 3× (mesma escala do jogador acima)"),
        lineup_row([sprite_item(sp.hive_boss(2)), sprite_item(sp.hive_boss(3))], "COLMEIA · ETAPAS 2 E 3 · 3×"),
        lineup_row([sprite_item(sp.sentinel_boss(True)), sprite_item(sp.reaper_boss(True)), sprite_item(sp.hive_boss(1, True))],
                   "VERSÕES _AVISO (piscam antes do ataque forte) · 3×"),
    ]
    return (f'<section style="display: flex; flex-direction: column; gap: 40px">'
            f'{section_heading(2, "Elenco na mesma escala", "tudo a 3× do tamanho de colisão; faixa 1× mostra a leitura real")}'
            f'{actual_size_strip()}{"".join(rows)}</section>')


def screens_section():
    screens = [
        (phase_one_scene(), "Fase 1 Órbita da Terra", "Fase 1 · Órbita da Terra",
         "Batedores em V, Serpentes nas laterais, Bastião atirando. Tiro duplo ativo."),
        (phase_two_scene(), "Fase 2 Cinturão de asteroides", "Fase 2 · Cinturão de asteroides",
         "Ceifador com leque de tiros; asteroides de perigo têm borda clara, rochas decorativas não."),
        (phase_three_scene(), "Fase 3 Nave-Mãe Colmeia", "Fase 3 · Nave-Mãe Colmeia",
         "Colmeia etapa 2 lançando Batedores pelos hangares; escudo e ajudante caindo."),
    ]
    columns = []
    for scene_markup, aria_label, title, caption in screens:
        columns.append(f'<div style="display: flex; flex-direction: column; gap: 14px; width: 480px">'
                       f'{phase_screen_svg(scene_markup, aria_label)}'
                       f'<div style="font-family: {TITLE_FONT}; font-size: 16px; font-weight: 700">{title}</div>'
                       f'<p style="margin: 0; font-size: 14px; color: {MUTED_TEXT_COLOR}; text-wrap: pretty">{caption}</p></div>')
    return (f'<section style="display: flex; flex-direction: column; gap: 28px">'
            f'{section_heading(3, "Simulação de tela", "480 × 720 em tamanho real, com HUD")}'
            f'<div style="display: flex; gap: 56px">{"".join(columns)}</div></section>')


def header_section():
    rules = [
        ("#5ee7ff", "Ciano é exclusivo do jogador (nave, escudo, vidas)."),
        ("#ff5d73", "Inimigos e chefes em tons quentes; apontam para baixo."),
        ("#ffffff", "Tiro inimigo: losango branco com borda coral e brilho."),
        ("#ffd166", "Tiro do jogador: feixe dourado. Brilho só em tiros e motores."),
    ]
    rules_markup = "".join(
        f'<li style="display: flex; align-items: center; gap: 12px; font-size: 16px">'
        f'<span style="width: 12px; height: 12px; border-radius: 2px; background: {color}; flex-shrink: 0"></span>{text}</li>'
        for color, text in rules)
    font_samples = "".join(
        f'<div style="font-family: {TITLE_FONT}; font-size: {size}px; font-weight: 700">PONTOS 012 450 · FASE 2</div>'
        for size in (18, 22, 28))
    return (f'<header style="display: flex; justify-content: space-between; gap: 64px">'
            f'<div style="display: flex; flex-direction: column; gap: 20px">'
            f'<div style="font-family: {TITLE_FONT}; font-size: 14px; letter-spacing: 3px; color: {MUTED_TEXT_COLOR}">GUIA DE ESTILO · V1 · PARA APROVAÇÃO</div>'
            f'<h1 style="margin: 0; font-family: {TITLE_FONT}; font-size: 72px; font-weight: 900; letter-spacing: 2px; line-height: 1">'
            f'<span style="color: #5ee7ff">SPACE</span> <span style="color: #ff5d73">SHOOTER</span></h1>'
            f'<p style="margin: 0; font-size: 18px; color: {MUTED_TEXT_COLOR}; max-width: 640px">Neo-arcade vetorial: formas geométricas, contorno fino, cores chapadas com sombra e luz derivadas. Shmup vertical 480 × 720.</p>'
            f'<ul style="margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 10px">{rules_markup}</ul></div>'
            f'<div style="width: 560px; flex-shrink: 0; display: flex; flex-direction: column; gap: 12px; padding: 24px; border: 1px solid {HAIRLINE_COLOR}; border-radius: 6px">'
            f'<div style="font-family: {TITLE_FONT}; font-size: 13px; letter-spacing: 1.5px; color: {MUTED_TEXT_COLOR}">FONTE SUGERIDA</div>'
            f'<div style="font-size: 20px; font-weight: 600">Orbitron (Google Fonts, OFL)</div>'
            f'<p style="margin: 0; font-size: 14px; color: {MUTED_TEXT_COLOR}">Para HUD, títulos e números. Textos longos (história entre fases): Chakra Petch, também OFL.</p>'
            f'{font_samples}'
            f'<div style="font-family: {BODY_FONT}; font-size: 18px">Chakra Petch 18 px · A frota invasora cruzou a órbita.</div></div></header>')


def build_board_html():
    body = (f'<div style="width: {BOARD_WIDTH}px; min-height: {BOARD_HEIGHT}px; box-sizing: border-box; padding: 72px; '
            f'display: flex; flex-direction: column; gap: 80px; background: {BOARD_BACKGROUND}; color: {TEXT_COLOR}; font-family: {BODY_FONT}">'
            f'{header_section()}{palette_section()}{lineup_section()}{screens_section()}</div>')
    data_properties = f'{{"$preview":{{"width":{BOARD_WIDTH},"height":{BOARD_HEIGHT}}}}}'
    return f'''<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>Space Shooter · Guia de estilo</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600;700;900&amp;family=Chakra+Petch:wght@400;600&amp;display=swap">
<style>
body{{margin:0;background:{BOARD_BACKGROUND}}}
</style>
</helmet>
{body}
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{data_properties}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
'''


if __name__ == "__main__":
    output_path = Path(sys.argv[1])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    html = build_board_html()
    assert "{{" not in html.split("<script type=")[0], "chaves duplas quebrariam o template"
    output_path.write_text(html, encoding="utf-8")
    print(f"{len(html) / 1024:.0f} KB")
