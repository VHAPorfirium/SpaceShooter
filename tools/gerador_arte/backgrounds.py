"""Cenarios com rolagem vertical (480 x 720), repetindo sem emenda na vertical."""
import math
import random

import sprites as sp
from effects import lumpy_circle_points

SCREEN_WIDTH = 480
SCREEN_HEIGHT = 720


def seamless_vertical_tile(content):
    """Repete o conteudo 720 px acima e abaixo: o que sai por uma borda entra pela outra."""
    return (content + sp.group(content, transform=f"translate(0 -{SCREEN_HEIGHT})")
            + sp.group(content, transform=f"translate(0 {SCREEN_HEIGHT})"))


def layer(name, content, base_color=None):
    background = sp.rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, fill=base_color) if base_color else ""
    return sp.Sprite(name, SCREEN_WIDTH, SCREEN_HEIGHT, background + seamless_vertical_tile(content))


def star_field(seed, amount, radius_range, color, opacity_range, area_left=0, area_right=SCREEN_WIDTH, twinkle_count=0):
    random_generator = random.Random(seed)
    stars = []
    for index in range(amount):
        center_x = round(random_generator.uniform(area_left, area_right), 1)
        center_y = round(random_generator.uniform(0, SCREEN_HEIGHT), 1)
        radius = round(random_generator.uniform(*radius_range), 2)
        opacity = round(random_generator.uniform(*opacity_range), 2)
        stars.append(sp.circle(center_x, center_y, radius, fill=color, opacity=opacity))
        if index < twinkle_count:
            ray = radius * 3
            stars.append(sp.line(center_x - ray, center_y, center_x + ray, center_y, stroke=color, stroke_width="0.6", opacity=round(opacity * 0.7, 2)))
            stars.append(sp.line(center_x, center_y - ray, center_x, center_y + ray, stroke=color, stroke_width="0.6", opacity=round(opacity * 0.7, 2)))
    return "".join(stars)


# ---------- fase 1: orbita da Terra ----------

def phase_one_background():
    gradient_identifier = sp.next_unique_identifier()
    random_generator = random.Random(101)
    cloud_streaks = []
    for _ in range(9):
        top = random_generator.uniform(0, SCREEN_HEIGHT)
        cloud_streaks.append(sp.rectangle(round(random_generator.uniform(4, 22), 1), round(top, 1), round(random_generator.uniform(8, 18), 1),
                                          round(random_generator.uniform(50, 140), 1), rx="5", fill="#1d4282", opacity="0.6"))
    content = (
        sp.ellipse(300, 180, 170, 90, fill="#142a55", opacity="0.35")
        + sp.ellipse(380, 520, 130, 160, fill="#1a1f4a", opacity="0.3")
        + sp.ellipse(200, 640, 120, 60, fill="#142a55", opacity="0.25")
        + sp.rectangle(0, 0, 44, SCREEN_HEIGHT, fill="#143064")
        + "".join(cloud_streaks)
    )
    atmosphere = (f'<defs><linearGradient id="{gradient_identifier}" x1="0" y1="0" x2="1" y2="0">'
                  f'<stop offset="0" stop-color="#2d63b8" stop-opacity="0.5"/><stop offset="1" stop-color="#2d63b8" stop-opacity="0"/>'
                  f'</linearGradient></defs>'
                  + sp.rectangle(44, 0, 34, SCREEN_HEIGHT, fill=f"url(#{gradient_identifier})")
                  + sp.rectangle(43, 0, 2, SCREEN_HEIGHT, fill="#4f86d6", opacity="0.45"))
    sprite = layer("fase1_fundo", content, "#0d1b3a")
    return sp.Sprite(sprite.name, sprite.width, sprite.height, sprite.body + atmosphere)


def phase_one_far_stars():
    return layer("fase1_estrelas_longe", star_field(111, 90, (0.5, 1.0), "#9fb3d9", (0.3, 0.65), area_left=60))


def phase_one_near_stars():
    return layer("fase1_estrelas_perto", star_field(121, 28, (1.1, 1.8), "#cfdaf0", (0.5, 0.8), area_left=60, twinkle_count=6))


# ---------- fase 2: cinturao de asteroides ----------

def phase_two_background():
    random_generator = random.Random(202)
    dust_bands = [
        sp.ellipse(130, 160, 240, 70, fill="#3a2418", opacity="0.55", transform="rotate(-18 130 160)"),
        sp.ellipse(370, 420, 260, 80, fill="#3a2418", opacity="0.45", transform="rotate(-24 370 420)"),
        sp.ellipse(160, 620, 220, 55, fill="#4a2c1a", opacity="0.3", transform="rotate(-14 160 620)"),
    ]
    dust_specks = [sp.circle(round(random_generator.uniform(0, SCREEN_WIDTH), 1), round(random_generator.uniform(0, SCREEN_HEIGHT), 1),
                             round(random_generator.uniform(0.6, 1.4), 2), fill="#5a3a26", opacity="0.4") for _ in range(70)]
    return layer("fase2_fundo", "".join(dust_bands) + "".join(dust_specks), "#2a1a12")


def phase_two_far_stars():
    return layer("fase2_estrelas_longe", star_field(211, 70, (0.5, 1.0), "#c9a98a", (0.25, 0.55)))


def decorative_rock(center_x, center_y, radius, seed):
    random_generator = random.Random(seed)
    factors = [round(random_generator.uniform(0.75, 1.0), 2) for _ in range(9)]
    outline = lumpy_circle_points(center_x, center_y, radius, factors, random_generator.uniform(0, math.pi))
    facet = lumpy_circle_points(center_x + radius * 0.15, center_y + radius * 0.2, radius * 0.6, factors[:7])
    return (sp.polygon(outline, fill="#1c120c", stroke="#3b281c", stroke_width="2", stroke_linejoin="round")
            + sp.polygon(facet, fill="#150d08", opacity="0.8"))


def phase_two_rocks():
    rock_positions = [(18, 90, 46), (462, 210, 38), (30, 380, 60), (455, 520, 52), (20, 650, 30),
                      (150, 300, 14), (330, 120, 11), (300, 600, 16), (470, 30, 22)]
    rocks = "".join(decorative_rock(x, y, radius, seed=index) for index, (x, y, radius) in enumerate(rock_positions))
    return layer("fase2_rochas", rocks)


# ---------- fase 3: nave-mae ----------

def phase_three_background():
    hexagon_radius = 20
    lattice = []
    for row_index in range(24):
        for column_index in range(-1, 15):
            center_x = 60 + column_index * math.sqrt(3) * hexagon_radius + (math.sqrt(3) * hexagon_radius / 2 if row_index % 2 else 0)
            center_y = row_index * 1.5 * hexagon_radius
            if 70 < center_x < 410:
                lattice.append(sp.polygon([(round(x, 2), round(y, 2)) for x, y in sp.hexagon_points(center_x, center_y, hexagon_radius - 1.5)],
                                          fill="none", stroke="#3a1331", stroke_width="1.5", opacity="0.55"))
    walls = [sp.rectangle(0, -10, 58, SCREEN_HEIGHT + 20, fill="#34112d"), sp.rectangle(422, -10, 58, SCREEN_HEIGHT + 20, fill="#34112d")]
    for panel_top in range(20, SCREEN_HEIGHT, 90):
        walls += [sp.rectangle(8, panel_top, 42, 72, rx="3", fill="none", stroke="#45183c", stroke_width="2"),
                  sp.rectangle(430, panel_top, 42, 72, rx="3", fill="none", stroke="#45183c", stroke_width="2"),
                  sp.rectangle(20, panel_top + 30, 18, 12, rx="2", fill="#45183c"),
                  sp.rectangle(442, panel_top + 30, 18, 12, rx="2", fill="#45183c")]
    walls += [sp.rectangle(58, -10, 4, SCREEN_HEIGHT + 20, fill="#45183c"), sp.rectangle(418, -10, 4, SCREEN_HEIGHT + 20, fill="#45183c")]
    return layer("fase3_fundo", "".join(lattice) + "".join(walls), "#2b0d24")


def phase_three_far_stars():
    return layer("fase3_estrelas_longe", star_field(311, 45, (0.5, 0.9), "#d9a5c9", (0.2, 0.45), area_left=70, area_right=410))


def structural_beam(top):
    parts = [sp.rectangle(0, top, SCREEN_WIDTH, 14, fill="#3a1331", stroke="#52204a", stroke_width="1.5")]
    for segment_left in range(0, SCREEN_WIDTH, 40):
        parts.append(sp.line(segment_left, top + 1, segment_left + 40, top + 13, stroke="#52204a", stroke_width="1.5"))
    for light_x in range(20, SCREEN_WIDTH, 80):
        parts += [sp.circle(light_x, top + 7, 5, fill="#ff3b3b", opacity="0.18"), sp.circle(light_x, top + 7, 2, fill="#ff3b3b", opacity="0.9")]
    return "".join(parts)


def vertical_strut(center_x, top, height):
    return (sp.rectangle(center_x - 5, top, 10, height, fill="#3a1331", stroke="#52204a", stroke_width="1.5")
            + sp.circle(center_x, top + height / 2, 1.8, fill="#ff3b3b", opacity="0.85"))


def phase_three_structures():
    content = (structural_beam(170) + structural_beam(480)
               + vertical_strut(120, 184, 70) + vertical_strut(360, 410, 70) + vertical_strut(250, 600, 60))
    return layer("fase3_estruturas", content)


def all_backgrounds():
    return [phase_one_background(), phase_one_far_stars(), phase_one_near_stars(),
            phase_two_background(), phase_two_far_stars(), phase_two_rocks(),
            phase_three_background(), phase_three_far_stars(), phase_three_structures()]
