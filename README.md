# Bunker 13 v2

**Reescrita do runtime.** A v1 foi um protótipo arquivado em
`../zombie-fps-legacy`; nada dela é fonte de verdade para a v2. A v2 não é uma
refatoração incremental: o núcleo é reescrito em torno de conteúdo JSON,
serviços e ferramentas de autoria.

- **Board de execução (fonte operacional):** [`KANBAN.md`](KANBAN.md)
- **Estratégia e decisões:** [`docs/planning/`](docs/planning/)
- **Legado histórico:** `../zombie-fps-legacy` (não usar como referência de implementação)

## Estado atual: Etapa 7 — Escala de conteúdo em andamento

- Vertical slice jogável e **Bunker 13 completo em JSON + geometria autoral**
  (4 salas, 4 portas, 4 wallbuys, 3 perks, caixa, 9 barricadas, 9 spawns).
- **6 armas em JSON**, loader/validador, testes `BUNKER13_OK`/`CONTENT_OK`.
- Entregue na Etapa 3: 2 slots, projétil/melee, explosões, granada/foguete/
  barris, `BarricadeSystem` com hold F, vãos de janela + IA de zumbi,
  `ViewmodelFactory` com `hands.glb` compartilhado e faca visual com
  `knife_slash`.
- Entregue também: rodadas 1→2 com HUD e game over; traps explosivas.
- Pendente: duas armas novas, wonder weapon e inimigo especial; a escala das
  armas (#16) fica como dívida visual.
- A geometria do mapa é autoral (GLB/`.blend`); builders antigos ficam em
  `src/maps/legacy/` apenas para exportação.

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

> Modelos organizados em `assets/models/`; fontes `.blend` e scripts em
> `source/blender/`. O `hands.glb` é único e compartilhado por todas as armas.
> Detalhes: `docs/planning/11-assets.md`.

## Etapas

| Etapa | Status |
|---|---|
| Etapa 1 — Preparação (`etapa1`) | Concluído |
| Etapa 2 — Conteúdo (`etapa2`) | Concluído |
| Etapa 3 — Gameplay (`etapa3`) | Concluído |
| Etapa 4 — Interações (`etapa4`) | Concluído |
| Etapa 5 — Ferramentas (`etapa5`) | Concluído |
| Etapa 6 — Quests (`etapa6`) | Concluído |
| Etapa 7 — Escala (`etapa7`) | Em andamento |
| Etapa 8 — Produção (`etapa8`) | Backlog |

## Gestão

- Execução: [Issues](https://github.com/AlanSCorreia/modular-zombies/issues) +
  milestones por etapa.
- Snapshot local: [`KANBAN.md`](KANBAN.md).
- Decisões: `docs/planning/19-decision-log.md`; avanços:
  `docs/planning/20-work-log.md`.
- Validação das docs: `python3 tools/check_docs.py` (offline) ou
  `--with-github`; o CI roda `DOCS_OK`.
- Métricas: `./tools/metrics_snapshot.sh`; raw em `metrics/raw/` (privado),
  agregados em `metrics/aggregates/`. Ver `metrics/README.md`.
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
1/2 ou scroll trocar arma • R recarregar • V faca • G granada • F interagir • ESC pausar
Clique em INICIAR para capturar o mouse.

## Testes

```bash
./tests/ci.sh     # docs + lógica + conteúdo + mapa + integração
./tests/bench.sh
```
