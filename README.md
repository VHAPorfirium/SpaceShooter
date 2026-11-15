# SpaceShooter

## Áudio

Todo o som passa pelo Autoload `GerenciadorAudio` (`script/gerenciador_audio.gd`):

- `GerenciadorAudio.tocar_musica(stream)` / `parar_musica()`: uma faixa por vez, em loop, no barramento **Musica**.
- `GerenciadorAudio.tocar_efeito(GerenciadorAudio.Efeito.X)`: efeitos curtos no barramento **Efeitos**.
- A música de cada fase e do chefe fica em `DadosFase.musica` e `DadosFase.musica_chefe`.
- O volume de cada barramento é ajustado no editor, na aba **Áudio** (`default_bus_layout.tres`).

Os arquivos `.wav` em `assets/audio/` são sintetizados pelo script `tools/gerar_audio.py`
(só biblioteca padrão do Python, sem problema de licença). Para gerar de novo:

```
python tools/gerar_audio.py
```

Para trocar um som, basta substituir o `.wav` mantendo o mesmo nome.
