# Bunker 13 v2

**Reescrita do runtime em paralelo.** A v1 foi arquivada em
`../zombie-fps-legacy` e permanece jogável como referência/rollback. A v2 não é
uma refatoração incremental: o núcleo será reescrito em torno de conteúdo
JSON, serviços e ferramentas de autoria.

- **Board de execução (fonte operacional):** [`KANBAN.md`](KANBAN.md)
- **Estratégia e decisões:** [`docs/planning/`](docs/planning/)
- **Legado:** `../zombie-fps-legacy`

## Estado atual — R0 (parcial)

A v2 tem apenas o **scaffold parcial**:

- Estrutura de pastas, assets copiados, `project.godot`, `main.tscn`.
- `Events` (EventBus) e `Content` (ContentRegistry) criados.
- **Faltam:** `Sfx`, `game_root.gd`, plugin do editor, schemas/JSON de conteúdo
  e testes.
- **Ainda não é jogável nem foi validada no editor.**

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

> A árvore atual ainda está na estrutura antiga; a reorganização é R0/R1.
> Detalhes: `docs/planning/11-assets.md`.

## Fases

| Fase | Status |
|---|---|
| R0 Preparação | Em revisão (docs atualizadas; importação pendente) |
| R1 Core + conteúdo | Backlog |
| R2 Loop de gameplay | Backlog |
| R3 Interações/UI/áudio | Backlog |
| R4 Ferramentas de mapa | Backlog |
| R5 Quests/Easter Eggs | Backlog |
| R6 Escala | Backlog |
| R7 Produção | Backlog |

## Executar

```bash
./run.sh
```

> Só será jogável após R2; a importação do projeto será validada no fim de R0.
