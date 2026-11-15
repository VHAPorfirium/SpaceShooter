"""Efeitos: explosoes, faiscas de acerto e flash de dano."""
import math
import random

import sprites as sp

EXPLOSION_COLORS = {
    "outer": "#ff6b3d",
    "middle": "#ffb347",
    "inner": "#ffe08a",
    "core": "#ffffff",
    "smoke": "#4a3346",
    "spark": "#ffd166",
    "shard": "#3a2a40",
    "shard_edge": "#ff9f45",
}
DAMAGE_FLASH_COLOR = "#ff3b3b"


def lumpy_circle_points(center_x, center_y, radius, radius_factors, rotation_radians=0.0):
    points = []
    for index, factor in enumerate(radius_factors):
        angle = 2 * math.pi * index / len(radius_factors) + rotation_radians
        points.append((round(center_x + math.cos(angle) * radius * factor, 2),
                       round(center_y + math.sin(angle) * radius * factor, 2)))
    return points


def star_points(center_x, center_y, outer_radius, inner_radius, ray_count, rotation_radians=-math.pi / 2):
    points = []
    for index in range(ray_count * 2):
        radius = outer_radius if index % 2 == 0 else inner_radius
        angle = rotation_radians + math.pi * index / ray_count
        points.append((round(center_x + math.cos(angle) * radius, 2), round(center_y + math.sin(angle) * radius, 2)))
    return points


class ExplosionRecipe:
    """Parametros fixos de uma explosao; cada quadro e o mesmo desenho em outro instante `progress` (0..1)."""

    def __init__(self, size, seed, is_large):
        random_generator = random.Random(seed)
        self.size = size
        self.center = size / 2
        self.max_radius = size / 2 * 0.94
        self.is_large = is_large
        self.layer_radius_factors = [[round(random_generator.uniform(0.82, 1.0), 2) for _ in range(14)] for _ in range(3)]
        self.smoke_angles = [random_generator.uniform(0, 2 * math.pi) for _ in range(8 if is_large else 5)]
        self.spark_angles = [random_generator.uniform(0, 2 * math.pi) for _ in range(16 if is_large else 9)]
        self.spark_speeds = [random_generator.uniform(0.75, 1.0) for _ in self.spark_angles]
        self.shards = [(random_generator.uniform(0, 2 * math.pi), random_generator.uniform(0.7, 1.0),
                        random_generator.uniform(-1, 1), random_generator.uniform(0.05, 0.09)) for _ in range(9 if is_large else 0)]
        self.secondary_blasts = [(random_generator.uniform(0, 2 * math.pi), random_generator.uniform(0.35, 0.55), start_time)
                                 for start_time in ((0.22, 0.38, 0.55) if is_large else ())]

    def _smoke(self, progress):
        if progress < 0.35:
            return ""
        opacity = round(min(0.75, (1 - progress) * 1.6), 2)
        puffs = []
        for angle in self.smoke_angles:
            distance = self.max_radius * (0.2 + 0.45 * progress)
            radius = self.max_radius * (0.16 + 0.14 * progress)
            puffs.append(sp.circle(round(self.center + math.cos(angle) * distance, 2), round(self.center + math.sin(angle) * distance, 2),
                                   round(radius, 2), fill=EXPLOSION_COLORS["smoke"], opacity=opacity))
        return "".join(puffs)

    def _fireball(self, center_x, center_y, progress, scale=1.0, end_time=0.8):
        if progress >= end_time:
            return ""
        growth = 1 - (1 - min(progress / 0.45, 1)) ** 2
        radius = (self.max_radius * 0.6 * growth + self.max_radius * 0.1) * scale
        fade = 1 if progress < 0.5 else (end_time - progress) / (end_time - 0.5)
        rotation = progress * 0.8
        layers = [
            sp.polygon(lumpy_circle_points(center_x, center_y, radius, self.layer_radius_factors[0], rotation),
                       fill=EXPLOSION_COLORS["outer"], opacity=round(fade, 2)),
            sp.polygon(lumpy_circle_points(center_x, center_y, radius * 0.72, self.layer_radius_factors[1], -rotation),
                       fill=EXPLOSION_COLORS["middle"], opacity=round(fade, 2)),
            sp.polygon(lumpy_circle_points(center_x, center_y, radius * 0.46, self.layer_radius_factors[2], rotation * 1.5),
                       fill=EXPLOSION_COLORS["inner"], opacity=round(fade, 2)),
        ]
        if progress < 0.45:
            layers.append(sp.circle(center_x, center_y, round(radius * 0.24 * (1.2 - progress), 2), fill=EXPLOSION_COLORS["core"]))
        return "".join(layers)

    def _shockwave(self, progress):
        if not 0.1 < progress < 0.95:
            return ""
        return sp.circle(self.center, self.center, round(self.max_radius * (0.25 + 0.72 * progress), 2), fill="none",
                         stroke=EXPLOSION_COLORS["inner"], stroke_width=round(self.max_radius * 0.07 * (1 - progress) + 0.4, 2),
                         opacity=round(1 - progress, 2))

    def _sparks(self, progress):
        sparks = []
        for angle, speed in zip(self.spark_angles, self.spark_speeds):
            start_distance = self.max_radius * (0.15 + 0.8 * progress * speed)
            length = self.max_radius * 0.2 * (1 - progress) + 1
            cosine, sine = math.cos(angle), math.sin(angle)
            sparks.append(sp.line(round(self.center + cosine * start_distance, 2), round(self.center + sine * start_distance, 2),
                                  round(self.center + cosine * (start_distance + length), 2), round(self.center + sine * (start_distance + length), 2),
                                  stroke=EXPLOSION_COLORS["spark"], stroke_width=round(max(0.8, self.size / 60), 2),
                                  stroke_linecap="round", opacity=round(max(0.0, 1 - progress * 0.95), 2)))
        return "".join(sparks)

    def _shards(self, progress):
        shards = []
        opacity = 1 if progress < 0.8 else round((1 - progress) / 0.2, 2)
        for angle, speed, spin, size_factor in self.shards:
            distance = self.max_radius * (0.12 + 0.82 * progress * speed)
            center_x = self.center + math.cos(angle) * distance
            center_y = self.center + math.sin(angle) * distance
            half_size = self.size * size_factor
            triangle = [(center_x, center_y - half_size), (center_x + half_size * 0.8, center_y + half_size * 0.6),
                        (center_x - half_size * 0.5, center_y + half_size * 0.4)]
            shards.append(sp.group(sp.polygon([(round(x, 2), round(y, 2)) for x, y in triangle], fill=EXPLOSION_COLORS["shard"],
                                              stroke=EXPLOSION_COLORS["shard_edge"], stroke_width="1.2", stroke_linejoin="round"),
                                   transform=f"rotate({round(spin * 360 * progress, 1)} {round(center_x, 2)} {round(center_y, 2)})",
                                   opacity=opacity))
        return "".join(shards)

    def _secondary_blasts(self, progress):
        blasts = []
        for angle, distance_factor, start_time in self.secondary_blasts:
            local_progress = (progress - start_time) / 0.35
            if 0 <= local_progress < 1:
                distance = self.max_radius * distance_factor
                blasts.append(self._fireball(round(self.center + math.cos(angle) * distance, 2), round(self.center + math.sin(angle) * distance, 2),
                                             local_progress, scale=0.38, end_time=1.0))
        return "".join(blasts)

    def frame(self, progress):
        return (self._smoke(progress) + self._shockwave(progress) + self._fireball(self.center, self.center, progress)
                + self._secondary_blasts(progress) + self._shards(progress) + self._sparks(progress))


def small_explosion_frames():
    recipe = ExplosionRecipe(48, seed=7, is_large=False)
    frame_count = 6
    return [sp.Sprite(f"explosao_pequena_{index + 1:02d}", 48, 48, recipe.frame((index + 0.5) / frame_count))
            for index in range(frame_count)]


def large_explosion_frames():
    recipe = ExplosionRecipe(160, seed=21, is_large=True)
    frame_count = 8
    return [sp.Sprite(f"explosao_grande_{index + 1:02d}", 160, 160, recipe.frame((index + 0.5) / frame_count))
            for index in range(frame_count)]


def hit_spark_frames():
    first = (sp.polygon(star_points(8, 8, 6, 1.2, 4), fill="#ffffff")
             + sp.circle(8, 8, 2, fill=EXPLOSION_COLORS["spark"]))
    second = (sp.polygon(star_points(8, 8, 7.6, 1.6, 8, -math.pi / 2 + math.pi / 8), fill=EXPLOSION_COLORS["spark"])
              + sp.polygon(star_points(8, 8, 4.5, 1, 4), fill="#ffffff"))
    third = (sp.circle(8, 8, 5, fill="none", stroke=EXPLOSION_COLORS["spark"], stroke_width="1", opacity="0.5")
             + "".join(sp.circle(round(8 + math.cos(angle) * 6.4, 2), round(8 + math.sin(angle) * 6.4, 2), 0.9, fill="#ffffff", opacity="0.8")
                       for angle in (math.pi / 4 + index * math.pi / 2 for index in range(4))))
    return [sp.Sprite(f"acerto_{index + 1:02d}", 16, 16, body) for index, body in enumerate((first, second, third))]


def damage_flash():
    gradient_identifier = sp.next_unique_identifier()
    body = (f'<defs><radialGradient id="{gradient_identifier}" cx="0.5" cy="0.5" r="0.72">'
            f'<stop offset="0.6" stop-color="{DAMAGE_FLASH_COLOR}" stop-opacity="0"/>'
            f'<stop offset="0.86" stop-color="{DAMAGE_FLASH_COLOR}" stop-opacity="0.22"/>'
            f'<stop offset="1" stop-color="{DAMAGE_FLASH_COLOR}" stop-opacity="0.55"/></radialGradient></defs>'
            + sp.rectangle(0, 0, 480, 720, fill=f"url(#{gradient_identifier})")
            + sp.rectangle(3, 3, 474, 714, rx="6", fill="none", stroke=DAMAGE_FLASH_COLOR, stroke_width="6", stroke_opacity="0.55"))
    return sp.Sprite("flash_dano", 480, 720, body)
