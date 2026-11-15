"""Gera todos os sons do Space Shooter em arquivos .wav (estilo arcade/chiptune).

Os sons são sintetizados do zero, então não há problema de licença.
Usa apenas a biblioteca padrão do Python 3.

Como rodar, a partir da raiz do projeto:
    python tools/gerar_audio.py

Saída:
    assets/audio/efeitos/*.wav  (sons curtos, sem repetição)
    assets/audio/musicas/*.wav  (faixas em loop)
"""

import math
import random
import struct
import wave
from dataclasses import dataclass
from pathlib import Path

TAXA_DE_AMOSTRAGEM = 22050
PICO_MAXIMO_APOS_NORMALIZAR = 0.9

PASTA_RAIZ_DO_PROJETO = Path(__file__).resolve().parent.parent
PASTA_DE_EFEITOS = PASTA_RAIZ_DO_PROJETO / "assets" / "audio" / "efeitos"
PASTA_DE_MUSICAS = PASTA_RAIZ_DO_PROJETO / "assets" / "audio" / "musicas"

ESCALA_MENOR_NATURAL = [0, 2, 3, 5, 7, 8, 10]
INTERVALOS_DO_ACORDE = {"menor": [0, 3, 7], "maior": [0, 4, 7]}


# ---------------------------------------------------------------------------
# Formas de onda e utilidades
# ---------------------------------------------------------------------------

def frequencia_da_nota_midi(numero_da_nota_midi: float) -> float:
    return 440.0 * 2.0 ** ((numero_da_nota_midi - 69) / 12.0)


def onda_quadrada(fase_em_ciclos: float, ciclo_de_trabalho: float = 0.5) -> float:
    return 1.0 if (fase_em_ciclos % 1.0) < ciclo_de_trabalho else -1.0


def onda_triangular(fase_em_ciclos: float) -> float:
    posicao_no_ciclo = fase_em_ciclos % 1.0
    return 4.0 * abs(posicao_no_ciclo - 0.5) - 1.0


def criar_buffer_vazio(duracao_em_segundos: float) -> list:
    return [0.0] * int(duracao_em_segundos * TAXA_DE_AMOSTRAGEM)


def somar_no_buffer(buffer_destino: list, amostras: list, indice_inicial: int) -> None:
    for deslocamento, amostra in enumerate(amostras):
        indice = indice_inicial + deslocamento
        if indice >= len(buffer_destino):
            break
        buffer_destino[indice] += amostra


def envelope_ataque_decaimento(indice_amostra: int, total_amostras: int,
                               tempo_ataque_segundos: float = 0.005) -> float:
    """Sobe rápido no início e cai linearmente até zero no fim da nota."""
    amostras_de_ataque = max(1, int(tempo_ataque_segundos * TAXA_DE_AMOSTRAGEM))
    if indice_amostra < amostras_de_ataque:
        return indice_amostra / amostras_de_ataque
    return max(0.0, 1.0 - (indice_amostra - amostras_de_ataque) / max(1, total_amostras - amostras_de_ataque))


def normalizar(amostras: list) -> list:
    pico = max((abs(amostra) for amostra in amostras), default=0.0)
    if pico == 0.0:
        return amostras
    fator = PICO_MAXIMO_APOS_NORMALIZAR / pico
    return [amostra * fator for amostra in amostras]


def salvar_wav(caminho_do_arquivo: Path, amostras: list) -> None:
    caminho_do_arquivo.parent.mkdir(parents=True, exist_ok=True)
    amostras_normalizadas = normalizar(amostras)
    with wave.open(str(caminho_do_arquivo), "wb") as arquivo_wav:
        arquivo_wav.setnchannels(1)
        arquivo_wav.setsampwidth(2)
        arquivo_wav.setframerate(TAXA_DE_AMOSTRAGEM)
        quadros = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, amostra)) * 32767))
            for amostra in amostras_normalizadas)
        arquivo_wav.writeframes(quadros)
    print(f"gerado: {caminho_do_arquivo.relative_to(PASTA_RAIZ_DO_PROJETO)}")


# ---------------------------------------------------------------------------
# Instrumentos (cada um devolve a lista de amostras de uma nota)
# ---------------------------------------------------------------------------

def tocar_nota_quadrada(nota_midi: float, duracao_segundos: float, volume: float,
                        ciclo_de_trabalho: float = 0.25) -> list:
    total_amostras = int(duracao_segundos * TAXA_DE_AMOSTRAGEM)
    frequencia = frequencia_da_nota_midi(nota_midi)
    return [
        onda_quadrada(frequencia * indice / TAXA_DE_AMOSTRAGEM, ciclo_de_trabalho)
        * envelope_ataque_decaimento(indice, total_amostras) * volume
        for indice in range(total_amostras)]


def tocar_nota_triangular(nota_midi: float, duracao_segundos: float, volume: float) -> list:
    total_amostras = int(duracao_segundos * TAXA_DE_AMOSTRAGEM)
    frequencia = frequencia_da_nota_midi(nota_midi)
    return [
        onda_triangular(frequencia * indice / TAXA_DE_AMOSTRAGEM)
        * min(1.0, 2.0 * envelope_ataque_decaimento(indice, total_amostras)) * volume
        for indice in range(total_amostras)]


def tocar_bumbo(volume: float) -> list:
    duracao_segundos = 0.14
    total_amostras = int(duracao_segundos * TAXA_DE_AMOSTRAGEM)
    amostras = []
    fase_em_ciclos = 0.0
    for indice in range(total_amostras):
        progresso = indice / total_amostras
        frequencia = 150.0 * (1.0 - progresso) + 40.0 * progresso
        fase_em_ciclos += frequencia / TAXA_DE_AMOSTRAGEM
        amostras.append(math.sin(2.0 * math.pi * fase_em_ciclos) * (1.0 - progresso) ** 2 * volume)
    return amostras


def tocar_ruido(duracao_segundos: float, volume: float, gerador_aleatorio: random.Random,
                agudo: bool = False) -> list:
    total_amostras = int(duracao_segundos * TAXA_DE_AMOSTRAGEM)
    amostras = []
    ruido_anterior = 0.0
    for indice in range(total_amostras):
        ruido_atual = gerador_aleatorio.uniform(-1.0, 1.0)
        # A diferença entre amostras vizinhas realça os agudos (som de chimbal)
        amostra = (ruido_atual - ruido_anterior) * 0.5 if agudo else ruido_atual
        ruido_anterior = ruido_atual
        amostras.append(amostra * (1.0 - indice / total_amostras) ** 2 * volume)
    return amostras


def tocar_caixa(volume: float, gerador_aleatorio: random.Random) -> list:
    ruido = tocar_ruido(0.13, volume, gerador_aleatorio)
    corpo = tocar_nota_triangular(55, 0.08, volume * 0.6)
    somar_no_buffer(ruido, corpo, 0)
    return ruido


# ---------------------------------------------------------------------------
# Efeitos sonoros
# ---------------------------------------------------------------------------

def varredura_de_frequencia(frequencia_inicial: float, frequencia_final: float,
                            duracao_segundos: float, forma_de_onda, volume: float) -> list:
    total_amostras = int(duracao_segundos * TAXA_DE_AMOSTRAGEM)
    amostras = []
    fase_em_ciclos = 0.0
    for indice in range(total_amostras):
        progresso = indice / total_amostras
        frequencia = frequencia_inicial * (frequencia_final / frequencia_inicial) ** progresso
        fase_em_ciclos += frequencia / TAXA_DE_AMOSTRAGEM
        amostras.append(forma_de_onda(fase_em_ciclos) * (1.0 - progresso) * volume)
    return amostras


def sequencia_de_notas(notas_e_duracoes: list, instrumento, volume: float) -> list:
    """Toca notas em sequência. Cada item é (nota_midi ou None para pausa, duração em segundos)."""
    amostras = []
    for nota_midi, duracao_segundos in notas_e_duracoes:
        if nota_midi is None:
            amostras.extend([0.0] * int(duracao_segundos * TAXA_DE_AMOSTRAGEM))
        else:
            amostras.extend(instrumento(nota_midi, duracao_segundos, volume))
    return amostras


def gerar_efeitos(gerador_aleatorio: random.Random) -> dict:
    def quadrada_meio_ciclo(fase):
        return onda_quadrada(fase, 0.5)

    def quadrada_estreita(fase):
        return onda_quadrada(fase, 0.25)

    explosao_do_chefe = tocar_ruido(1.4, 1.0, gerador_aleatorio)
    somar_no_buffer(explosao_do_chefe, varredura_de_frequencia(120, 30, 1.2, onda_triangular, 0.9), 0)

    dano = varredura_de_frequencia(500, 70, 0.45, quadrada_meio_ciclo, 0.8)
    somar_no_buffer(dano, tocar_ruido(0.25, 0.5, gerador_aleatorio), 0)

    aviso_do_chefe = sequencia_de_notas(
        [(81, 0.12), (None, 0.04), (76, 0.12), (None, 0.04)] * 3, tocar_nota_quadrada, 0.8)

    return {
        "tiro_jogador": varredura_de_frequencia(1200, 400, 0.09, quadrada_estreita, 0.6),
        "tiro_inimigo": varredura_de_frequencia(520, 180, 0.14, onda_triangular, 0.8),
        "explosao_inimigo": tocar_ruido(0.35, 1.0, gerador_aleatorio),
        "acerto_chefe": tocar_ruido(0.05, 0.7, gerador_aleatorio, agudo=True),
        "explosao_chefe": explosao_do_chefe,
        "dano_jogador": dano,
        "poder_coletado": sequencia_de_notas(
            [(72, 0.06), (76, 0.06), (79, 0.06), (84, 0.14)], tocar_nota_quadrada, 0.7),
        "aviso_chefe": aviso_do_chefe,
        "confirmar": sequencia_de_notas([(76, 0.06), (88, 0.12)], tocar_nota_quadrada, 0.7),
        "fase_concluida": sequencia_de_notas(
            [(72, 0.12), (76, 0.12), (79, 0.12), (84, 0.36), (79, 0.12), (84, 0.6)],
            tocar_nota_quadrada, 0.7),
        "vitoria": sequencia_de_notas(
            [(72, 0.15), (72, 0.15), (72, 0.15), (76, 0.45), (74, 0.15), (76, 0.15),
             (79, 0.3), (77, 0.15), (79, 0.15), (84, 1.2)],
            tocar_nota_quadrada, 0.7),
        "fim_de_jogo": sequencia_de_notas(
            [(67, 0.3), (66, 0.3), (65, 0.3), (64, 1.2)], tocar_nota_triangular, 0.9),
    }


# ---------------------------------------------------------------------------
# Músicas
# ---------------------------------------------------------------------------

@dataclass
class DefinicaoMusica:
    nome_do_arquivo: str
    batidas_por_minuto: int
    nota_tonica_midi: int
    progressao_de_acordes: list  # cada item: (grau em semitons a partir da tônica, "menor" ou "maior")
    intensidade_da_bateria: str  # "leve", "media" ou "intensa"
    semente_da_melodia: int
    tocar_arpejo: bool = True


DEFINICOES_DAS_MUSICAS = [
    DefinicaoMusica("menu", 100, 57, [(0, "menor"), (8, "maior"), (3, "maior"), (10, "maior")],
                    "leve", 11),
    DefinicaoMusica("fase_1", 126, 62, [(0, "menor"), (8, "maior"), (3, "maior"), (10, "maior")],
                    "media", 21),
    DefinicaoMusica("fase_2", 138, 60, [(0, "menor"), (8, "maior"), (10, "maior"), (7, "maior")],
                    "media", 37),
    DefinicaoMusica("fase_3", 148, 54, [(0, "menor"), (1, "maior"), (0, "menor"), (10, "maior")],
                    "intensa", 53),
    DefinicaoMusica("chefe", 160, 57, [(0, "menor"), (0, "menor"), (1, "maior"), (7, "maior")],
                    "intensa", 71, tocar_arpejo=False),
]

COMPASSOS_POR_MUSICA = 16
SEMICOLCHEIAS_POR_COMPASSO = 16
RITMOS_DA_MELODIA = [
    # Posição de início e duração (em semicolcheias) de cada nota no compasso
    [(0, 4), (4, 2), (6, 2), (8, 6), (14, 2)],
    [(0, 2), (2, 2), (4, 4), (10, 2), (12, 4)],
    [(0, 6), (6, 2), (8, 4), (12, 4)],
    [(0, 3), (3, 3), (6, 2), (8, 2), (10, 2), (12, 4)],
]


def nota_mais_proxima_na_escala(nota_midi: int, nota_tonica_midi: int) -> int:
    while (nota_midi - nota_tonica_midi) % 12 not in ESCALA_MENOR_NATURAL:
        nota_midi -= 1
    return nota_midi


def criar_motivo_melodico(gerador_aleatorio: random.Random) -> list:
    """Um compasso de melodia: ritmo + qual nota do acorde e passo na escala usar."""
    ritmo = gerador_aleatorio.choice(RITMOS_DA_MELODIA)
    return [(inicio, duracao, gerador_aleatorio.randint(0, 3), gerador_aleatorio.choice([0, 0, 1, -1]))
            for inicio, duracao in ritmo]


def nota_da_melodia(acorde_raiz_midi: int, intervalos_do_acorde: list, indice_nota_do_acorde: int,
                    passo_na_escala: int, nota_tonica_midi: int) -> int:
    oitava_extra = 12 if indice_nota_do_acorde >= len(intervalos_do_acorde) else 0
    nota = acorde_raiz_midi + intervalos_do_acorde[indice_nota_do_acorde % len(intervalos_do_acorde)] + oitava_extra
    nota = nota_mais_proxima_na_escala(nota + passo_na_escala * 2, nota_tonica_midi)
    return nota


def padrao_da_bateria(intensidade: str) -> dict:
    if intensidade == "leve":
        return {"bumbo": [0, 8], "caixa": [], "chimbal": [0, 4, 8, 12]}
    if intensidade == "media":
        return {"bumbo": [0, 6, 8], "caixa": [4, 12], "chimbal": list(range(0, 16, 2))}
    return {"bumbo": [0, 3, 6, 8, 11, 14], "caixa": [4, 12], "chimbal": list(range(16))}


def gerar_musica(definicao: DefinicaoMusica) -> list:
    gerador_aleatorio = random.Random(definicao.semente_da_melodia)
    duracao_semicolcheia = 60.0 / definicao.batidas_por_minuto / 4.0
    amostras_por_semicolcheia = int(duracao_semicolcheia * TAXA_DE_AMOSTRAGEM)
    total_semicolcheias = COMPASSOS_POR_MUSICA * SEMICOLCHEIAS_POR_COMPASSO
    buffer_musica = [0.0] * (amostras_por_semicolcheia * total_semicolcheias)

    # Estrutura A A B A: dá identidade e repetição, como numa música de arcade
    motivo_a = [criar_motivo_melodico(gerador_aleatorio) for _ in range(2)]
    motivo_b = [criar_motivo_melodico(gerador_aleatorio) for _ in range(2)]
    ordem_dos_motivos = [motivo_a, motivo_a, motivo_b, motivo_a]
    bateria = padrao_da_bateria(definicao.intensidade_da_bateria)

    for indice_compasso in range(COMPASSOS_POR_MUSICA):
        grau_do_acorde, qualidade_do_acorde = definicao.progressao_de_acordes[
            indice_compasso % len(definicao.progressao_de_acordes)]
        acorde_raiz_midi = definicao.nota_tonica_midi + grau_do_acorde
        intervalos_do_acorde = INTERVALOS_DO_ACORDE[qualidade_do_acorde]
        inicio_do_compasso = indice_compasso * SEMICOLCHEIAS_POR_COMPASSO * amostras_por_semicolcheia

        def posicao_em_amostras(semicolcheia_no_compasso: int) -> int:
            return inicio_do_compasso + semicolcheia_no_compasso * amostras_por_semicolcheia

        # Baixo em colcheias
        for semicolcheia in range(0, SEMICOLCHEIAS_POR_COMPASSO, 2):
            oitava = 12 if semicolcheia % 8 == 6 else 0
            nota_baixo = tocar_nota_triangular(acorde_raiz_midi - 24 + oitava, duracao_semicolcheia * 1.8, 0.30)
            somar_no_buffer(buffer_musica, nota_baixo, posicao_em_amostras(semicolcheia))

        # Arpejo baixinho em semicolcheias
        if definicao.tocar_arpejo:
            for semicolcheia in range(SEMICOLCHEIAS_POR_COMPASSO):
                intervalo = intervalos_do_acorde[semicolcheia % len(intervalos_do_acorde)]
                nota_arpejo = tocar_nota_quadrada(acorde_raiz_midi + intervalo, duracao_semicolcheia * 0.9, 0.06, 0.5)
                somar_no_buffer(buffer_musica, nota_arpejo, posicao_em_amostras(semicolcheia))

        # Melodia
        grupo_de_quatro_compassos = (indice_compasso // 4) % len(ordem_dos_motivos)
        motivo = ordem_dos_motivos[grupo_de_quatro_compassos][indice_compasso % 2]
        for inicio, duracao, indice_nota_do_acorde, passo_na_escala in motivo:
            nota = nota_da_melodia(acorde_raiz_midi + 12, intervalos_do_acorde, indice_nota_do_acorde,
                                   passo_na_escala, definicao.nota_tonica_midi)
            amostras_nota = tocar_nota_quadrada(nota, duracao * duracao_semicolcheia * 0.95, 0.20)
            somar_no_buffer(buffer_musica, amostras_nota, posicao_em_amostras(inicio))

        # Bateria
        for semicolcheia in bateria["bumbo"]:
            somar_no_buffer(buffer_musica, tocar_bumbo(0.55), posicao_em_amostras(semicolcheia))
        for semicolcheia in bateria["caixa"]:
            somar_no_buffer(buffer_musica, tocar_caixa(0.28, gerador_aleatorio), posicao_em_amostras(semicolcheia))
        for semicolcheia in bateria["chimbal"]:
            chimbal = tocar_ruido(0.03, 0.12, gerador_aleatorio, agudo=True)
            somar_no_buffer(buffer_musica, chimbal, posicao_em_amostras(semicolcheia))

    return buffer_musica


def main() -> None:
    gerador_aleatorio_dos_efeitos = random.Random(2026)
    for nome_do_efeito, amostras in gerar_efeitos(gerador_aleatorio_dos_efeitos).items():
        salvar_wav(PASTA_DE_EFEITOS / f"{nome_do_efeito}.wav", amostras)

    for definicao in DEFINICOES_DAS_MUSICAS:
        salvar_wav(PASTA_DE_MUSICAS / f"{definicao.nome_do_arquivo}.wav", gerar_musica(definicao))


if __name__ == "__main__":
    main()
