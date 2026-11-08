---
kind: planning
area: execution
status: active
stage: 8
owner: docs
last_reviewed: 2026-11-08
---

# Roadmap — v2

**Estratégia:** reescrever o runtime; a v1 fica arquivada apenas como histórico.
O board operacional é `../../KANBAN.md`.

**Regra:** uma fase ativa por vez; não avançar sem o aceite da anterior.

## Visão geral

| ID | Etapa | Objetivo | Status | Tamanho |
|---|---|---|---|---|
| `etapa1` | Etapa 1 — Preparação | Arquivar v1, scaffold v2, docs e Kanban | **Concluído** | S |
| `etapa2` | Etapa 2 — Conteúdo | Definições, registry, validador, Bunker 13 em JSON | **Concluído** | M |
| `etapa3` | Etapa 3 — Gameplay | Player, armas, zumbis, barricadas, rodadas, economia | **Concluído** | L |
| `etapa4` | Etapa 4 — Interações | Portas, compras, caixa, perks, HUD, menus, som | **Concluído** | M |
| `etapa5` | Etapa 5 — Ferramentas | Criar/validar/testar mapas no editor | **Concluído** | M |
| `etapa6` | Etapa 6 — Quests | QuestSystem, música, mecânica única, debug | **Concluído** | L |
| `etapa7` | Etapa 7 — Escala | 2º mapa, armas novas, wonder weapon, inimigo | **Concluído** | L |
| `etapa8` | Etapa 8 — Produção | Save, settings, export, pools, CI, performance | **Em andamento** | L |

## Etapa 1 — Preparação (concluída — tag `etapa1`)

**Entregáveis**
- v1 arquivada (histórico, não é fonte de verdade).
- v2 criada, assets copiados.
- Scaffold: `project.godot`, `main.tscn`, `Events`, `Content`, `Sfx`, `GameRoot`.
- Plugin `bunker_tools` (dock de validação/playtest).
- Importação validada no Godot.
- Docs, Kanban, Git, CI local, bench.
- Árvore híbrida definida: `content/` JSON, `assets/` binários, `source/` Blender.

**Aceite:** projeto importa; docs/árvore aprovados; `git` inicializado; `ci.sh` verde.

## Etapa 2 — Conteúdo (concluída)

**Entregue**
- Loader JSON + `ContentValidator`.
- 2 mapas (slice + Bunker 13) e 5 armas.
- Bunker 13 em JSON: 4 salas, 4 portas, 4 wallbuys, 3 perks, caixa,
  9 barricadas e 9 spawns.
- `Bunker13Builder` lendo `MapDefinition`.
- Modelos reorganizados em `assets/models/<categoria>/<id>/`.
- Testes `CONTENT_OK`, `LOGIC_OK` e `BUNKER13_OK`.

**Passa para a Etapa 3 — Gameplay:** mãos separadas, JSON de faca/explosivos, gameplay completo
do Bunker 13, 2 slots e barricadas funcionais.

**Aceite:** Bunker 13 carrega 100% por JSON; validador 0 erros; 0 refs de
asset quebradas; nenhum `if map_id` no núcleo e nenhum conteúdo em `.tres`.

## Etapa 3 — Gameplay (concluída)

**Já entregue na Etapa 1 — Preparação:** `PlayerController`, `WeaponController` (Glock/hitscan),
`ZombieEnemy`, HUD e loop mínimo (tiro, recarga, porta, morte).

**Já entregue na Etapa 3 — Gameplay:** `--map <id>`, `MapBuilderRegistry` (builder no
JSON), interações de porta/wallbuy/perk/caixa, smoke `MAP_OK` do Bunker 13,
Blender + fontes `.blend` de todas as armas e do zumbi, geometria autoral dos
mapas (GLB + `.blend`), **2 slots de arma** com troca, correção do softlock do
Bunker 13 (ondas alcançáveis + BFS salas/portas), `MapContext`/`Interactable`
tipados, harness extraído para `tests/`, pool/cache de áudio/tracer/animação,
HUD autoral em `scenes/ui/hud.tscn`, `Economy`/`RoundManager` separados,
armas hitscan/pellets/projectile + melee controller, `ExplosionSystem` com
`ExplosiveData`/barris encadeáveis, granada (G), lança-foguete e barris
autorais com dano por tiro e cadeia, `BarricadeSystem` (hold F, tábuas,
pontos e HUD de progresso), vãos de janela autorais, IA de zumbi
(approach/tear/climb/inside com fila por barricada), mãos compartilhadas
(`hands.glb`/`GripSocket`/`ViewmodelFactory`) com MP5 ponta a ponta e faca
autoral com `knife_slash`.

**Dívida visual (depois)**
- Normalização de escala/origem das armas (issue #16): AK-74, M870, pistol
  e wunder estão fora de metros.
- `BoxBuilder` compartilhado.
- Teste visual do Bunker 13.

**Transversal:** auditoria curta de redundância concluída em
`22-redundancy-audit.md` (issue #15), docs reorganizadas em índice + archive
(issue #18), validação automatizada com `tools/check_docs.py` (issue #19),
pipeline de métricas com snapshot por bloco (issue #20), faca visual com
`KNIFE_OK` (issue #17) e rodadas/game over (`ROUNDS_OK`, issue #21). A Etapa 3
foi aceita; a escala das armas (#16) fica como dívida visual.

**Pré-requisito atendido:** geometria do mapa autoral (ETAPA3.34–36).

**Aceite:** Bunker 13 jogável com geometria autoral; armas em JSON +
`ViewmodelFactory` (`hands.glb`); faca, explosivos e barricadas funcionando.

## Etapa 4 — Interações (concluída — tag `etapa4`)

**Já entregue:** portas/wallbuys/caixa/perks, HUD/menu/pause/game over,
HUD de progresso de barricada, prompts/hitmarker, traps explosivas
(issue #22), VFX/SFX + HUD de granadas (issue #23) e áudio/mixagem/volume
(issue #24).

**Dívida de polish:** vinheta e teste de UI dedicado.

**Aceite:** interações, UI e áudio do plano + explosivos/faca (checklist).

## Etapa 5 — Ferramentas de mapa (concluída — tag `etapa5`)

**Já entregue:** launcher “Bunker 13 v2 — Editor”, plugin `bunker_tools` + dock
com validador, criar/duplicar mapa (issue #25), playtest por mapa via override
one-shot (issue #26) e quickstart do autor (issue #27).

**Dívida:** marcadores 3D e content browser (P1/P2).

**Aceite:** criar/duplicar/validar/testar um mapa sem tocar no núcleo.

## Etapa 6 — Quests e Easter Eggs (concluída — tag `etapa6`)

**Já entregue:** `QuestSystem` + DTOs/triggers/recompensas (issue #28), quest
`quest.bunker13_music`, 3 rádios (issue #29), PowerMechanic (issue #30),
QuestValidator (issue #31) e main quest de 3 passos (issue #32).

**Dívida:** debug overlay e grafo visual (P1/P2).

**Aceite:** música secreta + main quest de 3 passos jogáveis — atendido.

## Etapa 7 — Escala de conteúdo (concluída — tag `etapa7`)

**Já entregue:** segundo mapa jogável `map.depot` (issue #33), duas armas novas
(issue #34), wonder weapon Ray Gun (issue #35), inimigo especial Brute
(issue #36) e teste `NO_CORE_OK`.

**Aceite:** 2º mapa + armas novas sem mudar o núcleo — atendido.

**Entregáveis**
- Segundo mapa com 2 mecânicas únicas.
- Duas armas novas.
- Uma wonder weapon.
- Um inimigo especial.
- Teste “sem mudança no núcleo”.

**Aceite:** novo mapa/arma sem alterar o núcleo; validador e testes verdes.

## Etapa 8 — Produção (em andamento)

**Próximo:** save/load versionado da run (issue #37).

**Entregáveis**
- Save/load versionado.
- Settings (sensibilidade, volume, qualidade).
- Exportação Linux + smoke test.
- Pool de áudio/efeitos.
- Navmesh pré-bakeada.
- CI (testes + validador) e soak test.

**Aceite:** build standalone abre e joga; FPS ≥ 40 na iGPU; zero softlocks.

## Trilhas transversais

| Trilha | Regra |
|---|---|
| Testes | Toda fase adiciona testes; gate obrigatório |
| Docs | Atualizar `docs/planning/` e Kanban ao fechar fase |
| Performance | Medir antes/depois de mudanças grandes |
| Conteúdo | Nenhum asset sem licença em `CREDITS.md` |
| Aceite | Golden path + `ci.sh` verde por fase |

## Definição de pronto

- Aceite da fase cumprido.
- Testes automatizados verdes.
- Conteúdo validado.
- Docs e Kanban atualizados.
- Sem softlock conhecido.
- Performance dentro do orçamento.

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Reescrita longa | Alto | Fatias verticais jogáveis |
| Perder polish | Alto | Paridade checklist |
| Ferramenta antes da base | Médio | Etapa 5 só após a Etapa 4 |
| Conteúdo inválido | Alto | Validador + CI |
| Performance em iGPU | Médio | Orçamento por mapa |
| Escopo crescer | Alto | Não-objetivos e Kanban |
