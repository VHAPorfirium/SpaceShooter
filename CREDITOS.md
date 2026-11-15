# Créditos e licenças

Space Shooter é um projeto acadêmico da disciplina Fundamentos de Jogos (CMP1199, PUC Goiás, 2026).

## Equipe

- Victor Hugo Aguiar Porfiro (gerente do projeto)
- Matteo Souza Caetano (desenvolvimento)
- Kevin Oliveira Matos
- Pedro Henrique Talalayv Gomes
- Guilherme Bastos Borges
- Eduardo Martins Ferreira

## Origem de cada recurso

| Recurso | Onde está | Origem | Licença / uso |
|---|---|---|---|
| Código do jogo (GDScript) | `script/`, `scenes/`, `data/` | Escrito pela equipe | Do projeto |
| Arte (naves, inimigos, chefes, efeitos, cenários, interface) | `assets/arte/` | Criada para o projeto com o Claude Design (Anthropic), a partir do guia de estilo da equipe; os SVGs são desenhados pelo código em `tools/gerador_arte/` | Original, feita para este jogo; sem uso de arte de terceiros |
| Ícone do jogo | `icon.svg`, `assets/icone/` | Montado a partir da nave do jogador (`jogador.svg`) | Igual à arte |
| Músicas e efeitos sonoros | `assets/audio/` | Sintetizados pelo script `tools/gerar_audio.py` (só biblioteca padrão do Python) | Original, feito para este jogo; sem amostras de terceiros |
| Fonte Orbitron | `assets/fontes/Orbitron.ttf` | Copyright 2018 The Orbitron Project Authors (github.com/theleagueof/orbitron), via Google Fonts | SIL Open Font License 1.1 (`assets/fontes/OFL_Orbitron.txt`) |
| Fonte Chakra Petch | `assets/fontes/ChakraPetch-*.ttf` | Copyright 2018 The Chakra Petch Project Authors (github.com/m4rc1e/Chakra-Petch), via Google Fonts | SIL Open Font License 1.1 (`assets/fontes/OFL_ChakraPetch.txt`) |
| Motor de jogo | — | Godot Engine 4.7.2 (godotengine.org) | MIT; o aviso de licença da Godot deve acompanhar o jogo exportado |

As fontes OFL podem ser usadas, embutidas e distribuídas com o jogo, desde que o arquivo de licença vá junto e as fontes não sejam vendidas sozinhas.

## Texto para o Anexo D do documento

> **Mídias e licenças.** A arte do jogo (naves, inimigos, chefes, efeitos, cenários e interface) foi criada especialmente para o projeto com o Claude Design, seguindo o guia de estilo aprovado pela equipe, e é gerada por código Python guardado no repositório (`tools/gerador_arte/`). As músicas e os efeitos sonoros foram sintetizados por um script próprio (`tools/gerar_audio.py`), sem amostras de terceiros. As fontes Orbitron e Chakra Petch são distribuídas pelo Google Fonts sob a SIL Open Font License 1.1, cujos textos acompanham o projeto em `assets/fontes/`. O jogo é feito na Godot Engine 4.7.2, de licença MIT. Assim, o risco R11 (licença de arte ou áudio inadequada) está tratado: todos os recursos são próprios ou de licença livre, com a fonte registrada.
