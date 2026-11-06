# Bunker 13 v2

**Reescrita do runtime.** A v1 foi um protótipo arquivado em
`../zombie-fps-legacy`; nada dela é fonte de verdade para a v2. A v2 não é uma
refatoração incremental: o núcleo é reescrito em torno de conteúdo JSON,
serviços e ferramentas de autoria.

- **Board de execução (fonte operacional):** [`KANBAN.md`](KANBAN.md)
- **Estratégia e decisões:** [`docs/planning/`](docs/planning/)
- **Legado histórico:** `../zombie-fps-legacy` (não usar como referência de implementação)

## Estado atual: Etapa 2 — Conteúdo concluída

- Vertical slice jogável (sala, porta, zumbi, Glock, HUD).
- **Bunker 13 completo em JSON + geometria autoral** (4 salas, 4 portas,
  4 wallbuys, 3 perks, caixa, 9 barricadas e 9 spawns).
- 5 armas em JSON, loader/validador, testes `BUNKER13_OK`.
- Modelos reorganizados em `assets/models/<categoria>/<id>/`.
- **Fontes `.blend` de todas as armas, do zumbi e dos mapas** em `source/blender/`.
- Git, CI, plugin `bunker_tools` e bench.

Etapa 3 — Gameplay em andamento: o Bunker 13 já abre com `--map map.bunker13`; faltam
janelas, barricadas, faca, explosivos, mãos separadas e 2 slots. A geometria do
mapa já é autoral (GLB/`.blend`); os builders antigos ficam em `src/maps/legacy/`
apenas para exportação.

## Decisões-chave

- Todas as armas serão modeladas no Blender e tratadas por `WeaponDefinition`.
- As mãos são um asset separado, compartilhado e reutilizado por todas as armas.
- A Glock 17 é só a primeira arma; não há caso especial no núcleo.
- **Conteúdo é JSON** (mapas, armas, explosivos, perks, quests); `.tres`/`.tscn`
  ficam para assets de engine (materiais, cenas, animações compostas).
- **Explosivos** (granadas, foguetes, traps, barris) e **faca (V)** fazem parte do combate.
- Assets: `assets/` (GLB/PNG/OGG/TTF), `source/blender/` (`.blend`), `content/` (JSON).

## Criar uma arma

Siga `docs/planning/14-weapon-workflow.md` e o template
`templates/weapon/weapon.json`. Resumo: referência → Blender (arma sem mãos) →
GLB → JSON → animações → validação → testes.

## Blender

```bash
./blender.sh                                              # visão geral
./blender.sh source/blender/weapons/glock17/glock17.blend # modelo específico
```

Fontes em `source/blender/`; GLBs em `assets/models/`. **Nenhum modelo 3D é
gerado em runtime** — o código só posiciona e anima. Detalhes em
`docs/planning/18-authored-assets.md`.

## Conteúdo e assets

```text
content/        JSON de jogo (mapas, armas, quests, explosivos)
schemas/        JSON Schemas
assets/         models, textures, materials, animations, audio, ui, vfx, shaders
source/blender/ .blend e scripts (fora do import do Godot)
```

> Modelos reorganizados; faltam as mãos separadas e as fontes `.blend` em `source/`.
> Detalhes: `docs/planning/11-assets.md`.

## Etapas

| Etapa | Status |
|---|---|
| Etapa 1 — Preparação (`etapa1`) | Concluído |
| Etapa 2 — Conteúdo (`etapa2`) | Concluído |
| Etapa 3 — Gameplay (`etapa3`) | Em andamento |
| Etapa 4 — Interações (`etapa4`) | Backlog |
| Etapa 5 — Ferramentas (`etapa5`) | Backlog |
| Etapa 6 — Quests (`etapa6`) | Backlog |
| Etapa 7 — Escala (`etapa7`) | Backlog |
| Etapa 8 — Produção (`etapa8`) | Backlog |

## Gestão

- Execução: [Issues](https://github.com/AlanSCorreia/modular-zombies/issues) +
  milestones por etapa.
- Snapshot local: [`KANBAN.md`](KANBAN.md).
- Decisões: `docs/planning/19-decision-log.md`; avanços:
  `docs/planning/20-work-log.md`.
- O subagente `doc-keeper` mantém a sincronização.

## Executar

```bash
./run.sh                         # jogo (slice)
./run.sh -- --map map.bunker13   # Bunker 13
./editor.sh                      # editor Godot
```

Atalhos: **Bunker 13 v2** e **Bunker 13 v2 — Editor**.

## Controles

WASD mover • Shift correr • Space pular • Mouse mirar/atirar
R recarregar • F interagir • Clique em INICIAR para capturar o mouse.

> Barricadas, faca (V), granadas e explosivos ainda não estão neste slice; entram na Etapa 3 — Gameplay.

## Testes

```bash
./tests/ci.sh     # LOGIC_OK, CONTENT_OK, BUNKER13_OK, MAP_OK, SLICE_OK
./tests/bench.sh
```
