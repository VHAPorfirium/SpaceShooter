"""Interface: logo, fundo do menu, barra do chefe e telas de transicao, vitoria e fim de jogo.

Nenhum SVG usa <text>: o importador da Godot (ThorVG) nao desenha texto.
Os textos variaveis (pontos, recorde, frases) ficam em Labels da Godot.
"""
import random

import sprites as sp
from backgrounds import star_field

INTERFACE_NEUTRAL = "#8b84c7"
INTERFACE_PANEL = "#14102b"
INTERFACE_PANEL_BORDER = "#3a3170"
OVERLAY_COLOR = "#0b0a1a"
VICTORY_COLOR = "#ffd166"
DEFEAT_COLOR = "#ff5d73"

# Letras geometricas proprias (grade 4 x 6), desenhadas como tracos.
LETTER_STROKES = {
    "S": "M4,0 L1,0 L0,1 L0,2 L1,3 L3,3 L4,4 L4,5 L3,6 L0,6",
    "P": "M0,6 L0,0 L3,0 L4,1 L4,2 L3,3 L0,3",
    "A": "M0,6 L0,1.5 L1.5,0 L2.5,0 L4,1.5 L4,6 M0,3.6 L4,3.6",
    "C": "M4,0 L1,0 L0,1 L0,5 L1,6 L4,6",
    "E": "M4,0 L0,0 L0,6 L4,6 M0,3 L3,3",
    "H": "M0,0 L0,6 M4,0 L4,6 M0,3 L4,3",
    "O": "M1,0 L3,0 L4,1 L4,5 L3,6 L1,6 L0,5 L0,1 Z",
    "T": "M0,0 L4,0 M2,0 L2,6",
    "R": "M0,6 L0,0 L3,0 L4,1 L4,2 L3,3 L0,3 M2,3 L4,6",
}
LETTER_WIDTH_UNITS = 4
LETTER_HEIGHT_UNITS = 6


def word_strokes(word, unit, letter_gap_units, left, top):
    paths = []
    for index, letter in enumerate(word):
        offset_x = left + index * (LETTER_WIDTH_UNITS + letter_gap_units) * unit
        paths.append(f'<path d="{LETTER_STROKES[letter]}" transform="translate({offset_x:g} {top:g}) scale({unit:g})"/>')
    return "".join(paths)


def word_width(word, unit, letter_gap_units):
    return (len(word) * LETTER_WIDTH_UNITS + (len(word) - 1) * letter_gap_units) * unit


def arcade_word(word, unit, letter_gap_units, center_x, top, main_color, shadow_color, light_color):
    """Palavra em tres camadas: sombra deslocada, halo (brilho sem filtro) e traco principal com filete de luz."""
    left = center_x - word_width(word, unit, letter_gap_units) / 2
    stroke_width_units = 1.15
    letters = word_strokes(word, unit, letter_gap_units, left, top)
    common = 'fill="none" stroke-linejoin="miter" stroke-linecap="square"'
    return (f'<g {common} stroke="{shadow_color}" stroke-width="{stroke_width_units:g}" transform="translate(4 4)">{letters}</g>'
            f'<g {common} stroke="{main_color}" stroke-width="{stroke_width_units * 2.1:g}" opacity="0.18">{letters}</g>'
            f'<g {common} stroke="{main_color}" stroke-width="{stroke_width_units * 1.5:g}" opacity="0.22">{letters}</g>'
            f'<g {common} stroke="{main_color}" stroke-width="{stroke_width_units:g}">{letters}</g>'
            f'<g {common} stroke="{light_color}" stroke-width="{stroke_width_units * 0.28:g}" opacity="0.85">{letters}</g>')


def logo():
    body = (
        sp.line(18, 49, 92, 49, stroke="#5ee7ff", stroke_width="2", stroke_linecap="round", opacity="0.6")
        + sp.line(308, 49, 382, 49, stroke="#5ee7ff", stroke_width="2", stroke_linecap="round", opacity="0.6")
        + sp.line(40, 57, 92, 57, stroke="#5ee7ff", stroke_width="1.2", stroke_linecap="round", opacity="0.35")
        + sp.line(308, 57, 360, 57, stroke="#5ee7ff", stroke_width="1.2", stroke_linecap="round", opacity="0.35")
        + arcade_word("SPACE", 7.2, 1.9, 200, 32, "#5ee7ff", "#073847", "#c9f8ff")
        + arcade_word("SHOOTER", 9.2, 1.45, 200, 92, "#ff5d73", "#4a0d18", "#ffd0d6")
        + sp.polygon([(40, 160), (360, 160), (350, 168), (50, 168)], fill="#ff5d73")
        + sp.polygon([(150, 160), (250, 160), (240, 168), (160, 168)], fill="#ffd0d6", opacity="0.7")
    )
    return sp.Sprite("logo", 400, 180, body)


def menu_background():
    random_generator = random.Random(404)
    far_fleet = []
    for _ in range(9):
        enemy = random_generator.choice([sp.scout_drone(), sp.serpent_drone()])
        far_fleet.append(sp.placed_svg(enemy, round(random_generator.uniform(40, 320), 1), round(random_generator.uniform(60, 150), 1),
                                       scale=round(random_generator.uniform(0.45, 0.65), 2), opacity="0.55"))
    flame = sp.player_engine_flame(1)
    body = (
        sp.rectangle(0, 0, 480, 720, fill="#14102b")
        + star_field(501, 110, (0.5, 1.1), "#8b84c7", (0.3, 0.7))
        + star_field(502, 24, (1.2, 1.8), "#d9d6f2", (0.5, 0.85), twinkle_count=5)
        + sp.placed_svg(sp.hive_boss(1), 390, 92, scale=0.85, opacity="0.5")
        + "".join(far_fleet)
        + sp.circle(240, 1190, 560, fill="#143064")
        + sp.path("M20,690 Q120,660 230,676 Q170,690 90,692 Z", fill="#1d4282", opacity="0.6")
        + sp.path("M300,668 Q380,650 470,672 Q400,682 330,678 Z", fill="#1d4282", opacity="0.5")
        + sp.circle(240, 1190, 566, fill="none", stroke="#2d63b8", stroke_width="8", stroke_opacity="0.4")
        + sp.path("M240,640 Q232,600 236,560 L244,560 Q248,600 240,640 Z", fill="#5ee7ff", opacity="0.25")
        + sp.placed_svg(flame, 240, 589, scale=2.6)
        + sp.placed_svg(sp.player_ship(), 240, 530, scale=2.6)
    )
    return sp.Sprite("menu_fundo", 480, 720, body)


def boss_bar_background():
    body = (sp.rectangle(0.5, 0.5, 299, 11, rx="5.5", fill="#1a1030", stroke="#ffffff", stroke_opacity="0.55")
            + sp.line(100, 2, 100, 10, stroke="#ffffff", stroke_opacity="0.25")
            + sp.line(200, 2, 200, 10, stroke="#ffffff", stroke_opacity="0.25"))
    return sp.Sprite("hud_barra_chefe_fundo", 300, 12, body)


def boss_bar_fill():
    """Branco de proposito: na Godot use TextureProgressBar.tint_progress com a cor do chefe."""
    body = (sp.rectangle(2, 2, 296, 8, rx="4", fill="#ffffff")
            + sp.rectangle(4, 3, 292, 2, rx="1", fill="#ffffff", opacity="0.6")
            + sp.rectangle(2, 7, 296, 3, rx="1.5", fill="#000000", opacity="0.18"))
    return sp.Sprite("hud_barra_chefe_preenchimento", 300, 12, body)


def corner_brackets(left, top, width, height, color, length=18, stroke_width=3):
    right, bottom = left + width, top + height
    corners = [f"M{left},{top + length} L{left},{top} L{left + length},{top}",
               f"M{right - length},{top} L{right},{top} L{right},{top + length}",
               f"M{right},{bottom - length} L{right},{bottom} L{right - length},{bottom}",
               f"M{left + length},{bottom} L{left},{bottom} L{left},{bottom - length}"]
    return "".join(sp.path(corner, fill="none", stroke=color, stroke_width=stroke_width, stroke_linecap="square") for corner in corners)


def panel(left, top, width, height, accent_color):
    return (sp.rectangle(left, top, width, height, rx="6", fill=INTERFACE_PANEL, fill_opacity="0.95",
                         stroke=INTERFACE_PANEL_BORDER, stroke_width="2")
            + corner_brackets(left - 6, top - 6, width + 12, height + 12, accent_color))


def transition_screen():
    body = (
        sp.rectangle(0, 0, 480, 720, fill=OVERLAY_COLOR, opacity="0.82")
        + panel(40, 240, 400, 240, INTERFACE_NEUTRAL)
        + sp.line(70, 312, 410, 312, stroke=INTERFACE_PANEL_BORDER, stroke_width="2")
        + sp.polygon([(232, 300), (240, 308), (248, 300)], fill=INTERFACE_NEUTRAL)
        + "".join(sp.polygon([(x, 452), (x + 8, 458), (x, 464)], fill=INTERFACE_NEUTRAL, opacity=str(opacity))
                  for x, opacity in ((222, 0.35), (234, 0.6), (246, 0.9)))
    )
    return sp.Sprite("tela_transicao", 480, 720, body)


def score_slot(top, accent_color):
    return (sp.rectangle(60, top, 360, 76, rx="4", fill="#0b0a1a", stroke=INTERFACE_PANEL_BORDER, stroke_width="2")
            + sp.rectangle(60, top, 6, 76, fill=accent_color))


def victory_emblem(color):
    wings = (sp.polygon([(240, 80), (180, 110), (130, 104), (200, 132)], fill=color)
             + sp.polygon([(240, 80), (300, 110), (350, 104), (280, 132)], fill=color)
             + sp.polygon([(240, 96), (200, 140), (170, 140), (226, 150)], fill=color, opacity="0.6")
             + sp.polygon([(240, 96), (280, 140), (310, 140), (254, 150)], fill=color, opacity="0.6"))
    star = sp.polygon([(240, 72), (247, 92), (268, 94), (252, 107), (257, 128), (240, 117), (223, 128), (228, 107), (212, 94), (233, 92)],
                      fill="#fff6d6", stroke=color, stroke_width="2", stroke_linejoin="round")
    return wings + star


def defeat_emblem(color):
    return (sp.polygon([(150, 88), (240, 128), (232, 140), (150, 104)], fill=color)
            + sp.polygon([(330, 88), (248, 124), (256, 138), (330, 104)], fill=color, opacity="0.75")
            + sp.polygon([(244, 120), (252, 136), (238, 150)], fill=color, opacity="0.5")
            + sp.circle(240, 82, 9, fill="none", stroke=color, stroke_width="3")
            + sp.line(234, 76, 246, 88, stroke=color, stroke_width="3", stroke_linecap="round"))


def result_screen(name, accent_color, emblem_markup):
    body = (
        sp.rectangle(0, 0, 480, 720, fill=OVERLAY_COLOR, opacity="0.82")
        + panel(36, 170, 408, 440, accent_color)
        + emblem_markup
        + sp.line(80, 262, 400, 262, stroke=accent_color, stroke_width="2", opacity="0.6")
        + score_slot(300, accent_color)
        + score_slot(396, INTERFACE_NEUTRAL)
        + sp.line(140, 540, 340, 540, stroke=INTERFACE_PANEL_BORDER, stroke_width="2")
    )
    return sp.Sprite(name, 480, 720, body)


def victory_screen():
    return result_screen("tela_vitoria", VICTORY_COLOR, victory_emblem(VICTORY_COLOR))


def game_over_screen():
    return result_screen("tela_fim_de_jogo", DEFEAT_COLOR, defeat_emblem(DEFEAT_COLOR))
