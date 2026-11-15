"""Gera a prancha de revisao dos assets novos (efeitos, cenarios e interface): project/Assets.dc.html."""
import sys
from pathlib import Path

import backgrounds as bg
import build_style_guide as guide
import effects as fx
import interface as ui
import sprites as sp

BOARD_HEIGHT = 3200


def labeled(svg_markup, file_name, size_text):
    return guide.lineup_item(svg_markup, file_name, size_text)


def frames_row(sprite_list, scale, caption):
    items = [labeled(sp.inline_svg(sprite, scale, label=sprite.name), f"_{sprite.name.rsplit('_', 1)[1]}", "") for sprite in sprite_list]
    first = sprite_list[0]
    full_caption = f"{caption} · {first.name.rsplit('_', 1)[0]}_01..{len(sprite_list):02d}.svg · {first.width:g} × {first.height:g} · {scale:g}×"
    return guide.lineup_row(items, full_caption.upper())


def stacked_layers(layer_sprites, label, scale=1.0):
    width, height = 480 * scale, 720 * scale
    content = "".join(sprite.body for sprite in layer_sprites)
    return (f'<svg width="{width:g}" height="{height:g}" viewBox="0 0 480 720" role="img" aria-label="{label}" '
            f'style="display: block; outline: 1px solid {guide.HAIRLINE_COLOR}">{content}</svg>')


def screen_column(svg_markup, title, caption, width):
    return (f'<div style="display: flex; flex-direction: column; gap: 12px; width: {width}px">{svg_markup}'
            f'<div style="font-family: {guide.TITLE_FONT}; font-size: 15px; font-weight: 700">{title}</div>'
            f'<p style="margin: 0; font-size: 14px; color: {guide.MUTED_TEXT_COLOR}; text-wrap: pretty">{caption}</p></div>')


def effects_section():
    damage_flash_preview = stacked_layers([bg.phase_one_background(), fx.damage_flash()], "flash de dano sobre a fase 1", 0.5)
    rows = [
        frames_row(fx.small_explosion_frames(), 2, "Explosão pequena"),
        frames_row(fx.large_explosion_frames(), 1, "Explosão grande"),
        guide.lineup_row([frames_row(fx.hit_spark_frames(), 4, "Acerto"),
                          labeled(damage_flash_preview, "flash_dano.svg", "480 × 720 · 0,5× sobre a fase 1")], "FAÍSCA DE ACERTO E FLASH DE DANO"),
    ]
    return (f'<section style="display: flex; flex-direction: column; gap: 40px">'
            f'{guide.section_heading(4, "Efeitos", "quadros em sequência, da esquerda para a direita")}{"".join(rows)}</section>')


def backgrounds_section():
    phases = [
        ([bg.phase_one_background(), bg.phase_one_far_stars(), bg.phase_one_near_stars()], "Fase 1 · Órbita da Terra",
         "fundo + estrelas_longe + estrelas_perto. O horizonte da Terra corre pela borda esquerda para a camada repetir sem emenda."),
        ([bg.phase_two_background(), bg.phase_two_far_stars(), bg.phase_two_rocks()], "Fase 2 · Cinturão de asteroides",
         "fundo + estrelas_longe + rochas. Rochas decorativas são mais escuras que o fundo; perigo tem borda clara."),
        ([bg.phase_three_background(), bg.phase_three_far_stars(), bg.phase_three_structures()], "Fase 3 · Nave-Mãe",
         "fundo + estrelas_longe + estruturas. Favo de mel no centro ecoa a Colmeia."),
    ]
    columns = [screen_column(stacked_layers(layers, title), title, caption, 480) for layers, title, caption in phases]
    asteroids = guide.lineup_row([guide.sprite_item(sp.hazard_asteroid(variant), 2) for variant in (1, 2, 3)], "ASTEROIDES DE PERIGO · 2×")
    return (f'<section style="display: flex; flex-direction: column; gap: 28px">'
            f'{guide.section_heading(5, "Cenários", "3 camadas por fase, 480 × 720, borda de cima encaixa na de baixo")}'
            f'<div style="display: flex; gap: 56px">{"".join(columns)}</div>{asteroids}</section>')


def interface_section():
    scale = 0.75
    width = 480 * scale
    menu_with_logo = sp.Sprite("menu", 480, 720, ui.menu_background().body + sp.placed_svg(ui.logo(), 240, 250))
    screens = [
        (sp.inline_svg(menu_with_logo, scale, label="menu com logo"), "menu_fundo + logo", "Centro livre entre y 170 e 470 para logo e textos."),
        (stacked_layers([bg.phase_two_background(), ui.transition_screen()], "transição", scale), "tela_transicao",
         "Título da fase acima do filete; frase de história abaixo."),
        (stacked_layers([bg.phase_three_background(), ui.victory_screen()], "vitória", scale), "tela_vitoria",
         "Rótulo VITÓRIA sob o emblema; caixas para pontos e recorde; aviso de tecla no rodapé."),
        (stacked_layers([bg.phase_one_background(), ui.game_over_screen()], "fim de jogo", scale), "tela_fim_de_jogo",
         "Mesma grade da vitória, com emblema quebrado em coral."),
    ]
    columns = [screen_column(svg_markup, title, caption, width) for svg_markup, title, caption in screens]
    tinted_preview = (f'<svg width="600" height="24" viewBox="0 0 300 12" aria-hidden="true" style="display: block">'
                      f'{ui.boss_bar_background().body}<g opacity="0.92">'
                      f'{sp.rectangle(2, 2, 207, 8, rx="4", fill="#e056fd")}</g></svg>')
    hud_items = guide.lineup_row([
        guide.sprite_item(ui.logo(), 1),
        guide.sprite_item(sp.life_icon(), 3),
        labeled(sp.inline_svg(ui.boss_bar_background(), 2, label="fundo da barra"), "hud_barra_chefe_fundo.svg", "300 × 12 · 2×"),
        labeled(sp.inline_svg(ui.boss_bar_fill(), 2, label="preenchimento"), "hud_barra_chefe_preenchimento.svg", "300 × 12 · 2× (branco)"),
        labeled(tinted_preview, "exemplo tingido", "tint_progress #e056fd, 70%"),
    ], "LOGO E HUD")
    return (f'<section style="display: flex; flex-direction: column; gap: 28px">'
            f'{guide.section_heading(6, "Interface", "telas a 0,75×; textos ficam em Labels da Godot (fonte Orbitron)")}'
            f'<div style="display: flex; gap: 48px">{"".join(columns)}</div>{hud_items}</section>')


def build_board_html():
    body = (f'<div style="width: {guide.BOARD_WIDTH}px; min-height: {BOARD_HEIGHT}px; box-sizing: border-box; padding: 72px; '
            f'display: flex; flex-direction: column; gap: 80px; background: {guide.BOARD_BACKGROUND}; color: {guide.TEXT_COLOR}; font-family: {guide.BODY_FONT}">'
            f'<div style="font-family: {guide.TITLE_FONT}; font-size: 14px; letter-spacing: 3px; color: {guide.MUTED_TEXT_COLOR}">SPACE SHOOTER · ASSETS V1 · EFEITOS, CENÁRIOS E INTERFACE</div>'
            f'{effects_section()}{backgrounds_section()}{interface_section()}</div>')
    data_properties = f'{{"$preview":{{"width":{guide.BOARD_WIDTH},"height":{BOARD_HEIGHT}}}}}'
    return f'''<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>Space Shooter · Assets</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600;700;900&amp;family=Chakra+Petch:wght@400;600&amp;display=swap">
<style>
body{{margin:0;background:{guide.BOARD_BACKGROUND}}}
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
    html = build_board_html()
    output_path.write_text(html, encoding="utf-8")
    print(f"{len(html) / 1024:.0f} KB")
