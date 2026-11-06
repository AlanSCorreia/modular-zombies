# AGENTS.md — Bunker 13 v2

## Projeto

- FPS de zumbis em **Godot 4.7.2** (GDScript). A raiz do projeto é esta pasta.
- A v1 em `zombie-fps-legacy` é histórica; **não usar como referência nem rollback**.
- Conteúdo de jogo (mapas, armas, inimigos, perks, barricadas) em
  `content/**/*.json`.
- `.tres`/`.tscn` apenas para assets de engine; `.glb` e texturas em `assets/`.
- Fontes Blender em `source/blender/` (com `.gdignore`).
- Todas as armas compartilham o mesmo `hands.glb`; mãos por arma são proibidas.

## Comandos

```bash
./run.sh          # jogar
./editor.sh       # abrir no editor
./tests/ci.sh     # CI completo
```

- Godot: `$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64`
  (ou `GODOT_BIN`).
- CI esperado: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `SLICE_OK`, `CI_OK`.

## Regras

- Mudança de gameplay exige teste em `tests/` e CI verde.
- Não commitar `.godot/`, builds ou logs.
- Planejamento em `docs/planning/`; status operacional em `KANBAN.md`.
- Uma fase ativa por vez; no máximo **1 item em Doing**.
- Responder e documentar em português.
