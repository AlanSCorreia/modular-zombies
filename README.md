# Bunker 13 v2

**Reescrita do runtime.** A v1 foi um protótipo arquivado em
`../zombie-fps-legacy`; nada dela é fonte de verdade para a v2. A v2 não é uma
refatoração incremental: o núcleo é reescrito em torno de conteúdo JSON,
serviços e ferramentas de autoria.

- **Board de execução (fonte operacional):** [`KANBAN.md`](KANBAN.md)
- **Estratégia e decisões:** [`docs/planning/`](docs/planning/)
- **Legado histórico:** `../zombie-fps-legacy` (não usar como referência de implementação)

## Estado atual — P0 concluído

Vertical slice jogável:

- Uma sala, porta comprável, zumbi, Glock com animações e HUD.
- Conteúdo em JSON (`content/`), carregado e validado por `ContentRegistry`.
- `Events`, `Sfx`, `GameRoot`, plugin `bunker_tools` e CI local.
- Git inicializado; v1 é apenas legado.

Ainda não é o Bunker 13 completo; o loop será expandido em R1–R3.

## Decisões-chave

- Todas as armas serão modeladas no Blender e tratadas por `WeaponDefinition`.
- As mãos são um asset separado, compartilhado e reutilizado por todas as armas.
- A Glock 17 é só a primeira arma; não há caso especial no núcleo.
- **Conteúdo é JSON** (mapas, armas, explosivos, perks, quests); `.tres`/`.tscn`
  ficam para assets de engine (materiais, cenas, animações compostas).
- **Explosivos** (granadas, foguetes, traps, barris) e **faca (V)** fazem parte do combate.
- Assets: `assets/` (GLB/PNG/OGG/TTF), `source/blender/` (`.blend`), `content/` (JSON).

## Conteúdo e assets

```text
content/        JSON de jogo (mapas, armas, quests, explosivos)
schemas/        JSON Schemas
assets/         models, textures, materials, animations, audio, ui, vfx, shaders
source/blender/ .blend e scripts (fora do import do Godot)
```

> A árvore atual ainda está na estrutura antiga; a reorganização é R1.
> Detalhes: `docs/planning/11-assets.md`.

## Fases

| Fase | Status |
|---|---|
| R0 Preparação | Concluído |
| R1 Core + conteúdo | Em andamento |
| R2 Loop de gameplay | Parcial (slice) |
| R3 Interações/UI/áudio | Backlog |
| R4 Ferramentas de mapa | Backlog |
| R5 Quests/Easter Eggs | Backlog |
| R6 Escala | Backlog |
| R7 Produção | Backlog |

## Executar

```bash
./run.sh          # jogo
./editor.sh       # editor Godot
```

Atalhos: **Bunker 13 v2** e **Bunker 13 v2 — Editor**.

## Controles

WASD mover • Shift correr • Space pular • Mouse mirar/atirar
R recarregar • F interagir • Clique em INICIAR para capturar o mouse.

> A faca (V), granadas e explosivos ainda não estão neste slice; entram em R2.

## Testes

```bash
./tests/ci.sh
./tests/bench.sh
```
