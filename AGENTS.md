# AGENTS.md — Bunker 13 v2

## Projeto

- FPS de zumbis em **Godot 4.7.2** (GDScript). A raiz do projeto é esta pasta.
- A v1 em `zombie-fps-legacy` é histórica; **não usar como referência nem rollback**.
- Conteúdo de jogo (mapas, armas, inimigos, perks, barricadas) em
  `content/**/*.json`.
- `.tres`/`.tscn` apenas para assets de engine; `.glb` e texturas em `assets/`.
- Fontes Blender em `source/blender/` (com `.gdignore`).
- **Nenhum modelo 3D é gerado em runtime.** Todo modelo tem `.blend` fonte em
  `source/blender/` e GLB em `assets/models/`; o código só posiciona e anima.
- `./blender.sh` abre a visão geral; edite o `.blend` e reexporte o GLB.
- Todas as armas compartilham o mesmo `hands.glb`; mãos por arma são proibidas.

## Comandos

```bash
./run.sh          # jogar
./editor.sh       # abrir no editor
./tests/ci.sh     # CI completo
./run.sh res://tests/test_runner.tscn -- --case slice   # integração headless
```

- Godot: `$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64`
  (ou `GODOT_BIN`).
- CI esperado: `DOCS_OK`, `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`, `SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `MELEE_OK`, `PROJECTILE_OK`, `EXPLOSION_OK`, `GRENADE_OK`, `ROCKET_OK`, `BARREL_OK`, `BARRICADE_OK`, `ZOMBIE_BARRICADE_OK`, `VIEWMODEL_OK`, `KNIFE_OK`, `ROUNDS_OK`, `TRAP_OK`, `FX_OK`, `SLICE_OK`, `CI_OK`.
- Docs: `python3 tools/check_docs.py` (offline); `--with-github` para issues.

## Regras

- Mudança de gameplay exige teste em `tests/` e CI verde.
- Não commitar `.godot/`, builds ou logs.
- Planejamento em `docs/planning/`; status operacional em `KANBAN.md`.
- Uma etapa ativa por vez; no máximo **1 item em Doing**.
- Responder e documentar em português.

## Próximo item e registro

- Antes de agir, leia `KANBAN.md`, `docs/planning/05-roadmap.md`,
  `06-backlog.md`, `19-decision-log.md` e `20-work-log.md`.
- O próximo item é o `Doing` do Kanban; se vazio, o topo de `Ready` da etapa
  ativa.
- Execução: issues/milestones no GitHub; `KANBAN.md` é o snapshot local.
- O subagente `doc-keeper` sincroniza KANBAN, logs e issues no fim do bloco.
- **Não perguntar "qual o próximo passo"**: decida pelos arquivos.
- Toda decisão estrutural nova vai para `19-decision-log.md`; todo avanço
  relevante vai para `20-work-log.md`.
- No fim de cada bloco, rode `./tools/metrics_snapshot.sh` (raw privado em
  `metrics/raw/`, agregados em `metrics/aggregates/`).
- Se surgir etapa ou task nova, atualize `06-backlog.md`, `KANBAN.md` e
  `05-roadmap.md` antes de executar.
