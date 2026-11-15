"""Exporta todos os SVGs do Space Shooter e gera a tabela de assets (ASSETS.md)."""
import sys
import xml.dom.minidom
from dataclasses import dataclass
from pathlib import Path

import backgrounds as bg
import effects as fx
import interface as ui
import sprites as sp


@dataclass(frozen=True)
class CatalogEntry:
    folder: str
    sprite: sp.Sprite
    purpose: str
    phases: str


def build_catalog():
    entries = []

    def add(folder, sprite_list, purpose, phases):
        for sprite in sprite_list:
            entries.append(CatalogEntry(folder, sprite, purpose, phases))

    all_phases = "1, 2 e 3"
    add("01_jogador", [sp.player_ship()], "Nave do jogador", all_phases)
    add("01_jogador", [sp.player_engine_flame(frame) for frame in (1, 2, 3)], "Chama do motor (animação, 3 quadros)", all_phases)
    add("01_jogador", [sp.player_shield()], "Escudo ativo", all_phases)
    add("01_jogador", [sp.helper_ship()], "Nave de ajuda", all_phases)
    add("02_inimigos", [sp.scout_drone()], "Batedor: rápido, desce reto", all_phases)
    add("02_inimigos", [sp.serpent_drone()], "Serpente: oscila na horizontal", all_phases)
    add("02_inimigos", [sp.bastion_drone()], "Bastião: blindado, atira (3 de vida)", all_phases)
    add("02_inimigos", [sp.bastion_drone_damaged()], "Bastião depois de levar tiro", all_phases)
    add("03_tiros_e_poderes", [sp.player_shot()], "Tiro do jogador", all_phases)
    add("03_tiros_e_poderes", [sp.enemy_shot()], "Tiro de inimigos e chefes", all_phases)
    add("03_tiros_e_poderes", [sp.power_up_double_shot()], "Poder: tiro duplo", all_phases)
    add("03_tiros_e_poderes", [sp.power_up_triple_shot()], "Poder: tiro triplo", all_phases)
    add("03_tiros_e_poderes", [sp.power_up_shield()], "Poder: escudo", all_phases)
    add("03_tiros_e_poderes", [sp.power_up_helper()], "Poder: nave de ajuda", all_phases)
    add("04_chefes", [sp.sentinel_boss()], "Chefe Sentinela-01", "1")
    add("04_chefes", [sp.sentinel_boss(warning=True)], "Sentinela piscando (aviso de ataque)", "1")
    add("04_chefes", [sp.reaper_boss()], "Chefe Ceifador", "2")
    add("04_chefes", [sp.reaper_boss(warning=True)], "Ceifador piscando (aviso de ataque)", "2")
    for stage, description in ((1, "roxa, intacta"), (2, "rosa, hangares abertos"), (3, "vermelha, núcleo exposto")):
        add("04_chefes", [sp.hive_boss(stage)], f"Colmeia etapa {stage} ({description})", "3")
        add("04_chefes", [sp.hive_boss(stage, warning=True)], f"Colmeia etapa {stage} piscando (aviso)", "3")
    add("05_efeitos", fx.small_explosion_frames(), "Explosão de drone (6 quadros)", all_phases)
    add("05_efeitos", fx.large_explosion_frames(), "Explosão de chefe (8 quadros)", all_phases)
    add("05_efeitos", fx.hit_spark_frames(), "Faísca de tiro acertando chefe (3 quadros)", all_phases)
    add("05_efeitos", [fx.damage_flash()], "Borda vermelha quando o jogador leva dano", all_phases)
    add("06_cenarios", [bg.phase_one_background()], "Fundo com rolagem (camada lenta)", "1")
    add("06_cenarios", [bg.phase_one_far_stars()], "Estrelas pequenas (parallax médio)", "1")
    add("06_cenarios", [bg.phase_one_near_stars()], "Estrelas médias (parallax rápido)", "1")
    add("06_cenarios", [bg.phase_two_background()], "Fundo com poeira cósmica", "2")
    add("06_cenarios", [bg.phase_two_far_stars()], "Estrelas pequenas (parallax médio)", "2")
    add("06_cenarios", [bg.phase_two_rocks()], "Rochas decorativas sem colisão (parallax rápido)", "2")
    add("06_cenarios", [sp.hazard_asteroid(variant) for variant in (1, 2, 3)], "Asteroide de perigo (com colisão)", "2")
    add("06_cenarios", [bg.phase_three_background()], "Fundo: paredes e favo da Nave-Mãe", "3")
    add("06_cenarios", [bg.phase_three_far_stars()], "Estrelas pequenas (parallax médio)", "3")
    add("06_cenarios", [bg.phase_three_structures()], "Vigas e luzes vermelhas (parallax rápido)", "3")
    add("07_interface", [ui.logo()], "Logotipo", "Menu")
    add("07_interface", [ui.menu_background()], "Tela inicial", "Menu")
    add("07_interface", [sp.life_icon()], "Ícone de vida no HUD", all_phases)
    add("07_interface", [ui.boss_bar_background()], "Barra de vida do chefe: fundo", all_phases)
    add("07_interface", [ui.boss_bar_fill()], "Barra de vida do chefe: preenchimento (branco, tingir na Godot)", all_phases)
    add("07_interface", [ui.transition_screen()], "Painel da frase de história entre fases", "Entre fases")
    add("07_interface", [ui.victory_screen()], "Moldura de vitória (pontos e recorde)", "Fim")
    add("07_interface", [ui.game_over_screen()], "Moldura de fim de jogo (pontos e recorde)", "Fim")
    return entries


def grouped_table_rows(entries):
    """Agrupa quadros de animacao (nome_01..nome_NN) numa linha so."""
    rows = []
    for entry in entries:
        name = entry.sprite.name
        size_text = f"{entry.sprite.width:g} × {entry.sprite.height:g}"
        base_name, _, suffix = name.rpartition("_")
        if suffix.isdigit() and rows and rows[-1]["base"] == base_name and rows[-1]["size"] == size_text:
            rows[-1]["last"] = suffix
            continue
        rows.append({"base": base_name if suffix.isdigit() else name, "first": suffix if suffix.isdigit() else None,
                     "last": None, "size": size_text, "entry": entry, "folder": entry.folder})
    lines = ["| Pasta | Arquivo | Tamanho (px) | Para que serve | Fase |", "|---|---|---|---|---|"]
    for row in rows:
        if row["first"] and row["last"]:
            file_text = f"{row['base']}_{row['first']}..{row['last']}.svg"
        elif row["first"]:
            file_text = f"{row['base']}_{row['first']}.svg"
        else:
            file_text = f"{row['base']}.svg"
        lines.append(f"| {row['folder']} | `{file_text}` | {row['size']} | {row['entry'].purpose} | {row['entry'].phases} |")
    return "\n".join(lines)


def export(output_directory):
    entries = build_catalog()
    for entry in entries:
        svg_text = sp.to_standalone_svg(entry.sprite)
        xml.dom.minidom.parseString(svg_text)
        target = output_directory / entry.folder / f"{entry.sprite.name}.svg"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(svg_text, encoding="utf-8")
    table = grouped_table_rows(entries)
    (output_directory / "ASSETS.md").write_text("# Space Shooter: lista de assets\n\n" + table + "\n", encoding="utf-8")
    print(f"{len(entries)} SVGs exportados")
    return table


if __name__ == "__main__":
    print(export(Path(sys.argv[1])))
