"""Biblioteca de sprites do Space Shooter.

Cada sprite e descrito por um `Sprite` (nome, largura, altura, marcacao interna).
A mesma marcacao serve para a prancha de estilo e para a exportacao em SVG.
"""
from dataclasses import dataclass
import itertools
import math

_unique_identifier_counter = itertools.count(1)


def next_unique_identifier():
    return f"u{next(_unique_identifier_counter)}"


@dataclass(frozen=True)
class Palette:
    main: str
    shade: str
    light: str
    outline: str
    core: str
    accent: str
    engine: str = "#ffb347"
    plate: str = ""


@dataclass(frozen=True)
class Sprite:
    name: str
    width: float
    height: float
    body: str


PLAYER_PALETTE = Palette("#5ee7ff", "#2bb8d6", "#c9f8ff", "#073847", "#0b2a3a", "#ffffff", "#9ff3ff")
HELPER_PALETTE = Palette("#ff8fd1", "#d9579f", "#ffd6ee", "#5a1b3f", "#3a0f2a", "#ffffff", "#ffc2e6")
SCOUT_PALETTE = Palette("#ff5d73", "#c7304a", "#ffb3be", "#4a0d18", "#2a0710", "#ffe0e5")
SERPENT_PALETTE = Palette("#c77dff", "#8e44d0", "#e9c9ff", "#2e0f4a", "#1c0830", "#f3e3ff")
BASTION_PALETTE = Palette("#ff9f45", "#c96a1c", "#ffd2a3", "#4a2408", "#2b1404", "#ffe2c4", plate="#e5822f")
SENTINEL_PALETTE = SCOUT_PALETTE
REAPER_PALETTE = Palette("#e056fd", "#a52dc4", "#f6c2ff", "#3d0a4a", "#22052b", "#fbd5ff")
HIVE_STAGE_ONE_PALETTE = Palette("#9b5de5", "#6a35b0", "#d3b8f7", "#24113f", "#160a28", "#e7dbff")
HIVE_STAGE_TWO_PALETTE = Palette("#d63384", "#9c1f5c", "#f5a8cc", "#3d0a22", "#200512", "#ffd1e6")
HIVE_STAGE_THREE_PALETTE = Palette("#ff3b3b", "#b81f1f", "#ffb0b0", "#3d0808", "#1f0404", "#ffe3e3")
WARNING_PALETTE = Palette("#ffffff", "#eceaff", "#ffffff", "#bdb8dc", "#d8d4f0", "#ffffff", "#ffffff", plate="#f4f2ff")

PLAYER_SHOT_COLOR = "#ffd166"
ENEMY_SHOT_COLOR = "#ffffff"
ENEMY_SHOT_BORDER_COLOR = "#ff5d73"
POWER_UP_COLORS = {
    "tiro_duplo": "#7bd88f",
    "tiro_triplo": "#ffd166",
    "escudo": "#5ee7ff",
    "ajudante": "#ff8fd1",
}


# ---------- primitivas ----------

def _format_attributes(attributes):
    parts = []
    for key, value in attributes.items():
        if value is None:
            continue
        parts.append(f'{key.rstrip("_").replace("_", "-")}="{value}"')
    return " ".join(parts)


def polygon(points, **attributes):
    points_text = " ".join(f"{x:g},{y:g}" for x, y in points)
    return f'<polygon points="{points_text}" {_format_attributes(attributes)}/>'


def mirror_points(points, width):
    return [(width - x, y) for x, y in points]


def path(data, **attributes):
    return f'<path d="{data}" {_format_attributes(attributes)}/>'


def circle(center_x, center_y, radius, **attributes):
    return f'<circle cx="{center_x:g}" cy="{center_y:g}" r="{radius:g}" {_format_attributes(attributes)}/>'


def ellipse(center_x, center_y, radius_x, radius_y, **attributes):
    return (f'<ellipse cx="{center_x:g}" cy="{center_y:g}" rx="{radius_x:g}" ry="{radius_y:g}" '
            f'{_format_attributes(attributes)}/>')


def rectangle(x, y, width, height, **attributes):
    return f'<rect x="{x:g}" y="{y:g}" width="{width:g}" height="{height:g}" {_format_attributes(attributes)}/>'


def line(x1, y1, x2, y2, **attributes):
    return f'<line x1="{x1:g}" y1="{y1:g}" x2="{x2:g}" y2="{y2:g}" {_format_attributes(attributes)}/>'


def group(content, **attributes):
    return f'<g {_format_attributes(attributes)}>{content}</g>'


def glow_filter(filter_identifier, blur_deviation):
    return (f'<filter id="{filter_identifier}" x="-100%" y="-100%" width="300%" height="300%">'
            f'<feGaussianBlur in="SourceGraphic" stdDeviation="{blur_deviation:g}" result="blur"/>'
            f'<feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge></filter>')


def glowing(content, blur_deviation):
    filter_identifier = next_unique_identifier()
    return f'<defs>{glow_filter(filter_identifier, blur_deviation)}</defs>' + group(content, filter=f"url(#{filter_identifier})")


def hexagon_points(center_x, center_y, radius, rotation_degrees=30):
    return [(center_x + radius * math.cos(math.radians(rotation_degrees + 60 * index)),
             center_y + radius * math.sin(math.radians(rotation_degrees + 60 * index))) for index in range(6)]


# ---------- 1. nave do jogador ----------

def _player_ship_shape(palette):
    outline = dict(stroke=palette.outline, stroke_width="0.8", stroke_linejoin="round")
    left_wing = [(11.2, 14), (1.5, 25.5), (1, 30), (7, 29), (11, 26.5)]
    left_tail_fin = [(12, 25), (9.5, 33), (12.5, 31)]
    left_canard = [(11.8, 9), (8.5, 13.5), (11.5, 13)]
    fuselage = [(15, 1), (18.5, 10), (19.5, 26), (17.5, 31), (12.5, 31), (10.5, 26), (11.5, 10)]
    spine = [(15, 3.5), (16.6, 10), (15.6, 24), (14.4, 24), (13.4, 10)]
    parts = [
        polygon(left_wing, fill=palette.shade, **outline),
        polygon(mirror_points(left_wing, 30), fill=palette.shade, **outline),
        line(10, 19, 3.5, 26.5, stroke=palette.light, stroke_width="0.8", opacity="0.7"),
        line(20, 19, 26.5, 26.5, stroke=palette.light, stroke_width="0.8", opacity="0.7"),
        polygon(left_tail_fin, fill=palette.shade, **outline),
        polygon(mirror_points(left_tail_fin, 30), fill=palette.shade, **outline),
        polygon(fuselage, fill=palette.main, **outline),
        polygon(left_canard, fill=palette.shade, **outline),
        polygon(mirror_points(left_canard, 30), fill=palette.shade, **outline),
        polygon(spine, fill=palette.light, opacity="0.55"),
        ellipse(15, 13.5, 2.3, 4.2, fill=palette.core),
        ellipse(14.3, 11.6, 0.7, 1.3, fill=palette.accent, opacity="0.75"),
        rectangle(13, 30.5, 4, 2.5, rx="0.8", fill=palette.core),
    ]
    return "".join(parts)


def player_ship():
    return Sprite("jogador", 30, 34, _player_ship_shape(PLAYER_PALETTE))


def player_engine_flame(frame_number):
    flame_tip_by_frame = {1: 11.5, 2: 9, 3: 10.5}
    inner_tip_by_frame = {1: 8, 2: 6, 3: 7}
    outer_tip = flame_tip_by_frame[frame_number]
    inner_tip = inner_tip_by_frame[frame_number]
    flame = (path(f"M1,0 L9,0 Q8,{outer_tip * 0.5:g} 5,{outer_tip:g} Q2,{outer_tip * 0.5:g} 1,0 Z",
                  fill=PLAYER_PALETTE.main, opacity="0.85")
             + path(f"M3,0 L7,0 Q6.4,{inner_tip * 0.5:g} 5,{inner_tip:g} Q3.6,{inner_tip * 0.5:g} 3,0 Z", fill="#ffffff"))
    return Sprite(f"jogador_motor_{frame_number:02d}", 10, 12, glowing(flame, 0.9))


def player_shield():
    ring = (circle(28, 28, 26, fill=PLAYER_PALETTE.main, fill_opacity="0.12", stroke=PLAYER_PALETTE.main,
                   stroke_width="2", stroke_opacity="0.9")
            + circle(28, 28, 22.5, fill="none", stroke=PLAYER_PALETTE.light, stroke_width="0.8", stroke_opacity="0.35")
            + path("M8.5,17 A22,22 0 0 1 20,6.5", fill="none", stroke="#ffffff", stroke_width="1.6",
                   stroke_linecap="round", opacity="0.8")
            + path("M47.5,39 A22,22 0 0 1 36,49.5", fill="none", stroke="#ffffff", stroke_width="1.2",
                   stroke_linecap="round", opacity="0.5"))
    return Sprite("jogador_escudo", 56, 56, glowing(ring, 1.2))


def helper_ship():
    return Sprite("ajudante", 18, 21, group(_player_ship_shape(HELPER_PALETTE), transform="translate(0 0.3) scale(0.6)"))


def life_icon():
    return Sprite("hud_vida", 16, 16, group(_player_ship_shape(PLAYER_PALETTE), transform="translate(0.94 0) scale(0.4706)"))


# ---------- 2. inimigos comuns ----------

def _enemy_engines(positions, palette, radius_x=2.2, radius_y=1.2):
    return glowing("".join(ellipse(x, y, radius_x, radius_y, fill=palette.engine) for x, y in positions), 0.8)


def _scout_shape(palette):
    outline = dict(stroke=palette.outline, stroke_width="0.8", stroke_linejoin="round")
    body = [(1, 1), (10, 5.5), (15, 3.5), (20, 5.5), (29, 1), (18, 17), (15, 27), (12, 17)]
    left_wing = [(1, 1), (10, 5.5), (12, 17)]
    parts = [
        _enemy_engines([(9.5, 2.6), (20.5, 2.6)], palette),
        polygon(body, fill=palette.main, **outline),
        polygon(left_wing, fill=palette.shade),
        polygon(mirror_points(left_wing, 30), fill=palette.shade),
        polygon(body, fill="none", **outline),
        polygon([(15, 5), (17, 10), (15, 23), (13, 10)], fill=palette.light, opacity="0.5"),
        circle(15, 11.5, 2.6, fill=palette.core),
        circle(15, 11.5, 1.2, fill=palette.accent),
    ]
    return "".join(parts)


def scout_drone():
    return Sprite("batedor", 30, 28, _scout_shape(SCOUT_PALETTE))


def serpent_drone():
    palette = SERPENT_PALETTE
    outline = dict(stroke=palette.outline, stroke_width="0.8", stroke_linejoin="round")
    left_fins = [
        "M11,5 Q5,1.5 1.5,2.5 Q4,5 3.5,7.5 Q7,9 11,9.5 Z",
        "M11,11 Q5,10 1,11.5 Q3.5,13.5 4,16 Q7.5,16 11,15 Z",
        "M12,17 Q8,18 5,20 Q7.5,21.5 9,22 Q11.5,20.5 13.5,19.5 Z",
    ]
    right_fins = [
        "M19,5 Q25,1.5 28.5,2.5 Q26,5 26.5,7.5 Q23,9 19,9.5 Z",
        "M19,11 Q25,10 29,11.5 Q26.5,13.5 26,16 Q22.5,16 19,15 Z",
        "M18,17 Q22,18 25,20 Q22.5,21.5 21,22 Q18.5,20.5 16.5,19.5 Z",
    ]
    body = [(15, 27), (21.5, 16), (19, 14.5), (19, 4.5), (15, 1), (11, 4.5), (11, 14.5), (8.5, 16)]
    parts = [_enemy_engines([(15, 1.6)], palette, 3, 1.2)]
    parts += [path(fin, fill=palette.shade, **outline) for fin in left_fins + right_fins]
    parts += [
        polygon(body, fill=palette.main, **outline),
        polygon([(8.5, 16), (21.5, 16), (15, 27)], fill=palette.shade, **outline),
        polygon([(15, 3), (16, 13), (15, 22), (14, 13)], fill=palette.light, opacity="0.5"),
        circle(15, 9.5, 2.3, fill=palette.core),
        circle(15, 9.5, 1.1, fill=palette.accent),
    ]
    return Sprite("serpente", 30, 28, "".join(parts))


def _bastion_shape(palette, damaged):
    outline = dict(stroke=palette.outline, stroke_width="0.8", stroke_linejoin="round")
    left_plate = [(1, 6), (6, 3.5), (6, 24), (1, 21.5)]
    left_plate_markup = polygon(left_plate, fill=palette.shade, **outline)
    if damaged:
        left_plate_markup = group(left_plate_markup, transform="translate(-0.6 2.2) rotate(-12 6 4)")
    parts = [
        _enemy_engines([(12, 1.8), (26, 1.8)], palette, 2.4, 1.1),
        left_plate_markup,
        polygon(mirror_points(left_plate, 38), fill=palette.shade, **outline),
        rectangle(13, 22, 12, 6, rx="1.5", fill=palette.core),
        rectangle(16.5, 26, 5, 6.5, rx="1", fill=palette.core),
        rectangle(16.5, 31, 5, 1.8, rx="0.6", fill=palette.light),
        rectangle(5, 2, 28, 23, rx="3.5", fill=palette.main, **outline),
        rectangle(8, 4.5, 22, 8, rx="1.5", fill=palette.shade, stroke=palette.outline, stroke_width="0.6"),
        rectangle(8, 14, 22, 8, rx="1.5", fill=palette.plate or palette.main, stroke=palette.outline, stroke_width="0.6"),
        line(9.5, 5.7, 28.5, 5.7, stroke=palette.light, stroke_width="0.8", opacity="0.7"),
        line(9.5, 15.2, 28.5, 15.2, stroke=palette.light, stroke_width="0.8", opacity="0.7"),
        rectangle(15, 7, 8, 3, rx="1.5", fill=palette.core),
        rectangle(16.5, 7.8, 5, 1.4, rx="0.7", fill=palette.accent),
    ]
    rivet_positions = [(10, 18.5), (28, 18.5), (10, 9.5), (28, 9.5)]
    if damaged:
        rivet_positions = rivet_positions[:3]
    parts += [circle(x, y, 0.8, fill=palette.light) for x, y in rivet_positions]
    if damaged:
        crack_style = dict(fill="none", stroke=palette.core, stroke_width="0.9", stroke_linejoin="round", stroke_linecap="round")
        parts += [
            polygon([(29.5, 2), (33, 2), (33, 9), (30.5, 6.5)], fill=palette.core),
            polygon([(8, 18), (12.5, 22), (8, 22)], fill=palette.core),
            ellipse(22, 18.5, 3.2, 2, fill=palette.core, opacity="0.35"),
            f'<polyline points="12,4.5 15,9 13,12 16,16.5" {_format_attributes(crack_style)}/>',
            f'<polyline points="27,14 24,18 26.5,21.5" {_format_attributes(crack_style)}/>',
            f'<polyline points="31,12 33,15" {_format_attributes(crack_style)}/>',
            circle(31.5, 5, 0.6, fill="#ffd166"),
            circle(9.5, 20.5, 0.5, fill="#ffd166"),
        ]
    return "".join(parts)


def bastion_drone():
    return Sprite("bastiao", 38, 34, _bastion_shape(BASTION_PALETTE, damaged=False))


def bastion_drone_damaged():
    return Sprite("bastiao_dano", 38, 34, _bastion_shape(BASTION_PALETTE, damaged=True))


# ---------- 3. chefes ----------

def _sentinel_shape(palette):
    outline = dict(stroke=palette.outline, stroke_linejoin="round")
    barrels = []
    for angle_degrees in (-40, -20, 0, 20, 40):
        barrel = (rectangle(42, 38, 4, 18, rx="1", fill=palette.core, stroke=palette.outline, stroke_width="0.6")
                  + rectangle(42, 52.5, 4, 3, rx="0.8", fill=palette.shade))
        barrels.append(group(barrel, transform=f"rotate({angle_degrees} 44 38)"))
    left_pod = [(1, 20), (10, 17), (14, 22), (14, 32), (10, 36), (1, 32)]
    outer_hexagon = [(22, 4), (66, 4), (80, 24), (66, 44), (22, 44), (8, 24)]
    inner_hexagon = [(28, 10), (60, 10), (70, 24), (60, 38), (28, 38), (18, 24)]
    parts = [_enemy_engines([(32, 3.2), (56, 3.2)], palette, 3, 1.4)]
    parts += barrels
    parts += [
        rectangle(4.5, 33, 4, 9, rx="1", fill=palette.core, stroke=palette.outline, stroke_width="0.6"),
        rectangle(79.5, 33, 4, 9, rx="1", fill=palette.core, stroke=palette.outline, stroke_width="0.6"),
        polygon(left_pod, fill=palette.shade, stroke_width="0.9", **outline),
        polygon(mirror_points(left_pod, 88), fill=palette.shade, stroke_width="0.9", **outline),
        polygon([(40, 4.5), (44, 0.8), (48, 4.5)], fill=palette.shade, stroke_width="0.7", **outline),
        polygon(outer_hexagon, fill=palette.main, stroke_width="1", **outline),
        polygon(inner_hexagon, fill=palette.shade, stroke_width="0.7", **outline),
    ]
    parts += [line(outer_x, outer_y, inner_x, inner_y, stroke=palette.outline, stroke_width="0.7")
              for (outer_x, outer_y), (inner_x, inner_y) in zip(outer_hexagon, inner_hexagon)]
    parts += [
        line(24, 6.5, 64, 6.5, stroke=palette.light, stroke_width="1", opacity="0.7"),
        circle(44, 24, 10, fill=palette.core, stroke=palette.outline, stroke_width="0.8"),
        circle(44, 24, 7.5, fill="none", stroke=palette.main, stroke_width="0.8", opacity="0.6"),
        circle(44, 24, 4.8, fill=palette.accent),
        circle(44, 24, 2, fill=palette.core),
        circle(5.5, 26, 1, fill=palette.light),
        circle(82.5, 26, 1, fill=palette.light),
    ]
    return "".join(parts)


def sentinel_boss(warning=False):
    palette = WARNING_PALETTE if warning else SENTINEL_PALETTE
    return Sprite("sentinela_aviso" if warning else "sentinela", 88, 58, _sentinel_shape(palette))


def _reaper_shape(palette):
    outline = dict(stroke=palette.outline, stroke_linejoin="round")
    left_claw = [(29, 26.5), (27, 34), (33, 28.5)]
    parts = [
        _enemy_engines([(43, 9), (57, 9)], palette, 2.6, 1.4),
        path("M50,53 L57.5,35 Q76,27 99,3 Q82,13 65,15 L57,8 L50,2 L43,8 L35,15 Q18,13 1,3 Q24,27 42.5,35 Z",
             fill=palette.main, stroke_width="1", **outline),
        path("M42,33 Q25,24 9,9 Q24,17 37,19 L44,26 Z", fill=palette.shade),
        path("M58,33 Q75,24 91,9 Q76,17 63,19 L56,26 Z", fill=palette.shade),
        path("M3.5,4.5 Q24,22 41,31", fill="none", stroke=palette.light, stroke_width="0.9", opacity="0.6"),
        path("M96.5,4.5 Q76,22 59,31", fill="none", stroke=palette.light, stroke_width="0.9", opacity="0.6"),
        polygon(left_claw, fill=palette.shade, stroke_width="0.7", **outline),
        polygon(mirror_points(left_claw, 100), fill=palette.shade, stroke_width="0.7", **outline),
        path("M50,30 L53,37 L50,50 L47,37 Z", fill=palette.light, opacity="0.6"),
        ellipse(50, 19, 6, 8, fill=palette.core, stroke=palette.outline, stroke_width="0.8"),
        ellipse(50, 20, 2.8, 4, fill=palette.accent),
        line(50, 2.5, 50, 10, stroke=palette.light, stroke_width="0.8", opacity="0.6"),
    ]
    return "".join(parts)


def reaper_boss(warning=False):
    palette = WARNING_PALETTE if warning else REAPER_PALETTE
    return Sprite("ceifador_aviso" if warning else "ceifador", 100, 54, _reaper_shape(palette))


HIVE_HULL_PATH = ("M22,4 L102,4 Q118,8 121,24 Q122,40 116,50 L94,71 Q62,77 30,71 "
                  "L8,50 Q2,40 3,24 Q6,8 22,4 Z")


def _honeycomb_cells(palette):
    cells = []
    hexagon_radius = 6
    horizontal_spacing = math.sqrt(3) * hexagon_radius
    vertical_spacing = 1.5 * hexagon_radius
    for row_index in range(10):
        for column_index in range(14):
            center_x = column_index * horizontal_spacing + (horizontal_spacing / 2 if row_index % 2 else 0)
            center_y = row_index * vertical_spacing
            filled = (row_index * 7 + column_index * 3) % 5 == 0
            cells.append(polygon(hexagon_points(center_x, center_y, hexagon_radius - 0.6, 30),
                                 fill=palette.shade if filled else "none",
                                 stroke=palette.outline, stroke_width="0.7", stroke_opacity="0.45"))
    return "".join(cells)


def _hive_hangar(center_x, palette, opened, show_scout):
    top = 55
    if not opened:
        return (rectangle(center_x - 9, top, 18, 11, rx="3", fill=palette.shade, stroke=palette.outline, stroke_width="0.8")
                + line(center_x, top + 1, center_x, top + 10, stroke=palette.outline, stroke_width="0.8")
                + line(center_x - 7, top + 4, center_x + 7, top + 4, stroke=palette.light, stroke_width="0.6", opacity="0.5")
                + line(center_x - 7, top + 7, center_x + 7, top + 7, stroke=palette.light, stroke_width="0.6", opacity="0.5"))
    hangar = [
        rectangle(center_x - 9, top, 18, 11, rx="3", fill="#120610", stroke=palette.outline, stroke_width="0.8"),
        glowing(rectangle(center_x - 6, top + 7.5, 12, 2, rx="1", fill="#ffb347", opacity="0.8"), 1),
        rectangle(center_x - 11.5, top + 1, 2.5, 9, rx="0.8", fill=palette.shade, stroke=palette.outline, stroke_width="0.6"),
        rectangle(center_x + 9, top + 1, 2.5, 9, rx="0.8", fill=palette.shade, stroke=palette.outline, stroke_width="0.6"),
    ]
    if show_scout:
        hangar.append(group(_scout_shape(SCOUT_PALETTE), transform=f"translate({center_x - 6:g} {top + 1:g}) scale(0.4)"))
    return "".join(hangar)


def _hive_shape(palette, stage, warning):
    clip_identifier = next_unique_identifier()
    hull_outline = dict(stroke=palette.outline, stroke_width="1.2", stroke_linejoin="round")
    hangars_open = stage >= 2
    parts = [_enemy_engines([(40, 3.2), (84, 3.2)], palette, 3.2, 1.4)]
    if stage >= 2:
        left_spike = [(9, 45), (0.8, 59), (13, 52)]
        parts += [polygon(left_spike, fill=palette.shade, **hull_outline),
                  polygon(mirror_points(left_spike, 124), fill=palette.shade, **hull_outline)]
    if stage >= 3:
        lower_spike = [(24, 66), (19, 75.5), (31, 70.5)]
        parts += [polygon(lower_spike, fill=palette.shade, **hull_outline),
                  polygon(mirror_points(lower_spike, 124), fill=palette.shade, **hull_outline)]
    parts += [
        f'<defs><clipPath id="{clip_identifier}"><path d="{HIVE_HULL_PATH}"/></clipPath></defs>',
        polygon([(48, 4.5), (62, 0.8), (76, 4.5)], fill=palette.shade, stroke=palette.outline, stroke_width="0.8"),
        path(HIVE_HULL_PATH, fill=palette.main),
        group(_honeycomb_cells(palette), clip_path=f"url(#{clip_identifier})"),
        path("M10,30 Q28,19 45,26", fill="none", stroke=palette.shade, stroke_width="3", stroke_linecap="round"),
        path("M114,30 Q96,19 79,26", fill="none", stroke=palette.shade, stroke_width="3", stroke_linecap="round"),
        path("M12,40 Q26,34 40,40", fill="none", stroke=palette.light, stroke_width="0.9", opacity="0.5"),
        path("M112,40 Q98,34 84,40", fill="none", stroke=palette.light, stroke_width="0.9", opacity="0.5"),
        path(HIVE_HULL_PATH, fill="none", **hull_outline),
        path("M24,6.5 L100,6.5", fill="none", stroke=palette.light, stroke_width="1", opacity="0.55"),
        polygon(hexagon_points(62, 32, 14), fill=palette.core, stroke=palette.shade, stroke_width="1.6"),
    ]
    if stage == 1:
        parts += [polygon(hexagon_points(62, 32, 9.5), fill=palette.shade, stroke=palette.outline, stroke_width="0.8"),
                  line(62, 23, 62, 41, stroke=palette.light, stroke_width="0.8", opacity="0.6"),
                  line(54, 32, 70, 32, stroke=palette.light, stroke_width="0.8", opacity="0.6")]
    elif stage == 2:
        parts += [polygon(hexagon_points(62, 32, 9.5), fill=palette.shade, stroke=palette.outline, stroke_width="0.8"),
                  circle(62, 32, 4.2, fill=palette.accent),
                  line(54, 32, 57.5, 32, stroke=palette.light, stroke_width="0.8", opacity="0.6"),
                  line(66.5, 32, 70, 32, stroke=palette.light, stroke_width="0.8", opacity="0.6")]
    else:
        core_markup = circle(62, 32, 9, fill=palette.accent) + circle(62, 32, 5.5, fill="#ffffff")
        parts += [glowing(core_markup, 0 if warning else 2.2),
                  polygon([(53, 26), (49, 23), (51, 29)], fill=palette.shade, stroke=palette.outline, stroke_width="0.6")]
    for hangar_center_x in (34, 62, 90):
        parts.append(_hive_hangar(hangar_center_x, palette, hangars_open, show_scout=(stage == 2 and hangar_center_x == 62 and not warning)))
    parts += [circle(x, 67.5, 1, fill=palette.light) for x in (46, 78)]
    if stage >= 3:
        crack_style = dict(fill="none", stroke=palette.outline, stroke_width="1.3", stroke_linejoin="round", stroke_linecap="round")
        inner_glow_style = dict(fill="none", stroke=palette.accent, stroke_width="0.5", stroke_linejoin="round", opacity="0.9")
        crack_paths = ["M22,5 L27,13 L24,19 L31,26", "M102,6 L96,14 L100,21 L93,27",
                       "M76,34 L84,40 L82,47 L90,52", "M44,38 L38,45 L41,50"]
        for crack in crack_paths:
            parts.append(path(crack, **crack_style))
            parts.append(path(crack, **inner_glow_style))
        parts += [path("M116,13 L121,22 L113,20 Z", fill=palette.core),
                  path("M5,36 L2.5,44 L9,41 Z", fill=palette.core)]
    return "".join(parts)


def hive_boss(stage, warning=False):
    palettes = {1: HIVE_STAGE_ONE_PALETTE, 2: HIVE_STAGE_TWO_PALETTE, 3: HIVE_STAGE_THREE_PALETTE}
    palette = WARNING_PALETTE if warning else palettes[stage]
    name = f"colmeia_etapa{stage}" + ("_aviso" if warning else "")
    return Sprite(name, 124, 76, _hive_shape(palette, stage, warning))


# ---------- 4. projeteis ----------

def player_shot():
    beam = (rectangle(0.6, 0.5, 3.8, 13, rx="1.9", fill=PLAYER_SHOT_COLOR)
            + rectangle(1.75, 2, 1.5, 10, rx="0.75", fill="#fff6d6"))
    return Sprite("tiro_jogador", 5, 14, glowing(beam, 0.6))


def enemy_shot():
    orb = (polygon([(4, 0.6), (7.4, 4), (4, 7.4), (0.6, 4)], fill=ENEMY_SHOT_COLOR,
                   stroke=ENEMY_SHOT_BORDER_COLOR, stroke_width="1.1", stroke_linejoin="round")
           + circle(4, 4, 1.1, fill="#ffffff"))
    return Sprite("tiro_inimigo", 8, 8, glowing(orb, 0.5))


# ---------- 5. poderes ----------

def _power_up_frame(color, icon_markup):
    return (circle(11, 11, 10, fill="#10101e", stroke=color, stroke_width="1.8")
            + circle(11, 11, 8.6, fill=color, opacity="0.18")
            + icon_markup)


def power_up_double_shot():
    color = POWER_UP_COLORS["tiro_duplo"]
    icon = (line(8.5, 6.5, 8.5, 15.5, stroke=color, stroke_width="2.2", stroke_linecap="round")
            + line(13.5, 6.5, 13.5, 15.5, stroke=color, stroke_width="2.2", stroke_linecap="round"))
    return Sprite("poder_tiro_duplo", 22, 22, _power_up_frame(color, icon))


def power_up_triple_shot():
    color = POWER_UP_COLORS["tiro_triplo"]
    icon = "".join(line(11, 16, end_x, end_y, stroke=color, stroke_width="2", stroke_linecap="round")
                   for end_x, end_y in ((6.2, 7), (11, 5.5), (15.8, 7)))
    return Sprite("poder_tiro_triplo", 22, 22, _power_up_frame(color, icon))


def power_up_shield():
    color = POWER_UP_COLORS["escudo"]
    icon = path("M11,5 L16,7 L15.5,11.5 Q14.2,15.5 11,17.2 Q7.8,15.5 6.5,11.5 L6,7 Z",
                fill=color, fill_opacity="0.35", stroke=color, stroke_width="1.6", stroke_linejoin="round")
    return Sprite("poder_escudo", 22, 22, _power_up_frame(color, icon))


def power_up_helper():
    color = POWER_UP_COLORS["ajudante"]
    icon = group(_player_ship_shape(HELPER_PALETTE), transform="translate(6 5.2) scale(0.34)")
    return Sprite("poder_ajudante", 22, 22, _power_up_frame(color, icon))


# ---------- utilidades de saida ----------

def to_standalone_svg(sprite):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{sprite.width:g}" height="{sprite.height:g}" '
            f'viewBox="0 0 {sprite.width:g} {sprite.height:g}">{sprite.body}</svg>\n')


def inline_svg(sprite, scale=1, label=None):
    accessibility = f'role="img" aria-label="{label}"' if label else 'aria-hidden="true"'
    return (f'<svg width="{sprite.width * scale:g}" height="{sprite.height * scale:g}" '
            f'viewBox="0 0 {sprite.width:g} {sprite.height:g}" overflow="visible" {accessibility} '
            f'style="display: block">{sprite.body}</svg>')


def placed_svg(sprite, center_x, center_y, rotation_degrees=0, scale=1, opacity=None):
    transform = f"translate({center_x - sprite.width * scale / 2:g} {center_y - sprite.height * scale / 2:g})"
    if scale != 1:
        transform += f" scale({scale:g})"
    placed = group(sprite.body, transform=transform, opacity=opacity)
    if rotation_degrees:
        return group(placed, transform=f"rotate({rotation_degrees:g} {center_x:g} {center_y:g})")
    return placed



# ---------- asteroides de perigo (fase 2) ----------

ASTEROID_HAZARD_COLORS = {"main": "#6b4a35", "shade": "#4a3122", "light": "#a07a5a", "outline": "#1a0f0a"}


def hazard_asteroid(variant_number):
    size_by_variant = {1: 40, 2: 56, 3: 72}
    size = size_by_variant[variant_number]
    center = size / 2
    radius_factors = {1: [0.92, 0.8, 0.95, 0.85, 0.9, 0.78, 0.93, 0.86],
                      2: [0.9, 0.95, 0.8, 0.92, 0.84, 0.94, 0.79, 0.9, 0.88],
                      3: [0.94, 0.84, 0.9, 0.96, 0.8, 0.9, 0.86, 0.95, 0.82, 0.91]}[variant_number]
    outer_points = []
    for index, factor in enumerate(radius_factors):
        angle = 2 * math.pi * index / len(radius_factors) - math.pi / 2
        outer_points.append((round(center + math.cos(angle) * center * factor, 2),
                             round(center + math.sin(angle) * center * factor, 2)))
    colors = ASTEROID_HAZARD_COLORS
    craters = [(0.38, 0.4, 0.13), (0.62, 0.62, 0.1), (0.6, 0.3, 0.07)]
    body = [polygon(outer_points, fill=colors["main"], stroke=colors["outline"], stroke_width=f"{size / 40:g}", stroke_linejoin="round"),
            path(f"M{outer_points[-2][0]:g},{outer_points[-2][1]:g} L{outer_points[-1][0]:g},{outer_points[-1][1]:g} "
                 f"L{outer_points[0][0]:g},{outer_points[0][1]:g} L{outer_points[1][0]:g},{outer_points[1][1]:g}",
                 fill="none", stroke=colors["light"], stroke_width=f"{size / 30:g}", stroke_linejoin="round", stroke_linecap="round")]
    lower_half = outer_points[2:len(outer_points) // 2 + 3]
    body.append(polygon([(center, center)] + lower_half, fill=colors["shade"], opacity="0.7"))
    body += [circle(size * x, size * y, size * r, fill=colors["shade"], stroke=colors["outline"],
                    stroke_width=f"{size / 70:g}") for x, y, r in craters]
    return Sprite(f"asteroide_{variant_number:02d}", size, size, "".join(body))
