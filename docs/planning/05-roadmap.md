# Roadmap — v2

**Estratégia:** reescrever o runtime; a v1 fica arquivada apenas como histórico.
O board operacional é `../../KANBAN.md`.

**Regra:** uma fase ativa por vez; não avançar sem o aceite da anterior.

## Visão geral

| Fase | Nome | Objetivo | Status | Tamanho |
|---|---|---|---|---|
| R0 | Preparação | Arquivar v1, scaffold v2, docs e Kanban | **Concluído** | S |
| R1 | Core + conteúdo | Definições, registry, validador, Bunker 13 em JSON | **Concluído** | M |
| R2 | Loop de gameplay | Player, armas, zumbis, barricadas, rodadas, economia | **Em andamento** | L |
| R3 | Interações/UI/áudio | Portas, compras, caixa, perks, HUD, menus, som | Backlog | M |
| R4 | Ferramentas de mapa | Criar/validar/testar mapas no editor | Backlog | M |
| R5 | Quests/Easter Eggs | QuestSystem, música, mecânica única, debug | Backlog | L |
| R6 | Escala de conteúdo | 2º mapa, armas novas, wonder weapon, inimigo | Backlog | L |
| R7 | Produção | Save, settings, export, pools, CI, performance | Backlog | L |

## R0 — Preparação (concluído — P0)

**Entregáveis**
- v1 arquivada (histórico, não é fonte de verdade).
- v2 criada, assets copiados.
- Scaffold: `project.godot`, `main.tscn`, `Events`, `Content`, `Sfx`, `GameRoot`.
- Plugin `bunker_tools` (dock de validação/playtest).
- Importação validada no Godot.
- Docs, Kanban, Git, CI local, bench.
- Árvore híbrida definida: `content/` JSON, `assets/` binários, `source/` Blender.

**Aceite:** projeto importa; docs/árvore aprovados; `git` inicializado; `ci.sh` verde.

## R1 — Core + conteúdo (concluído)

**Entregue**
- Loader JSON + `ContentValidator`.
- 2 mapas (slice + Bunker 13) e 5 armas.
- Bunker 13 em JSON: 4 salas, 4 portas, 4 wallbuys, 3 perks, caixa,
  9 barricadas e 9 spawns.
- `Bunker13Builder` lendo `MapDefinition`.
- Modelos reorganizados em `assets/models/<categoria>/<id>/`.
- Testes `CONTENT_OK`, `LOGIC_OK` e `BUNKER13_OK`.

**Passa para R2:** mãos separadas, JSON de faca/explosivos, gameplay completo
do Bunker 13, 2 slots e barricadas funcionais.

**Aceite:** Bunker 13 carrega 100% por JSON; validador 0 erros; 0 refs de
asset quebradas; nenhum `if map_id` no núcleo e nenhum conteúdo em `.tres`.

## R2 — Loop de gameplay (em andamento)

**Já entregue no P0:** `PlayerController`, `WeaponController` (Glock/hitscan),
`ZombieEnemy`, HUD e loop mínimo (tiro, recarga, porta, morte).

**Pendente**
- 2 slots de arma e troca.
- `HandsRig`/`ViewmodelFactory` com mãos compartilhadas.
- Validar o workflow com uma segunda arma.
- Faca (V, corte diagonal) e explosivos (granadas, foguete, barris).
- `BarricadeSystem`: hold F, tábuas, arranque e entrada do zumbi.
- `RoundManager`/economia completos e efeitos.
- Testes de explosivos/faca e loop completo.

**Aceite:** Bunker 13 jogável; armas em JSON + `HandsRig`; faca, explosivos e
barricadas funcionando.

## R3 — Interações, UI e áudio

**Entregáveis**
- `InteractionSystem` tipado (`Interactable`).
- Portas, wallbuys, caixa e perks.
- HUD/progresso de reparo, áudio e VFX de barricada.
- Traps explosivas e props explosivos vindos do JSON do mapa.
- HUD, menu, pause, game over.
- Áudio 2D/3D, música, mixagem e VFX de explosão/faca.
- HUD de equipamento (granadas).
- Prompts, hitmarker, vinheta e feedback de pontos.
- Teste de interação e UI.

**Aceite:** interações, UI e áudio do plano + explosivos/faca (checklist).

## R4 — Ferramentas de mapa

**Entregáveis**
- Launcher “Bunker 13 v2 — Editor”.
- Plugin `bunker_tools` + dock.
- Criar/duplicar/validar/testar mapa.
- Templates e documentação do autor.
- Marcadores 3D e content browser (P1, podem ficar para depois).

**Aceite:** criar/duplicar/validar/testar um mapa sem tocar no núcleo.

## R5 — Quests e Easter Eggs

**Entregáveis**
- `QuestSystem` + `QuestStep`/`Reward`.
- Triggers: interagir, matar, entrar, coletar.
- Recompensas: pontos, música, arma, perk.
- 3 rádios no Bunker 13 (música secreta).
- `Bunker13PowerMechanic` (mecânica única de mapa).
- Validador de grafo/softlock e debug overlay.

**Aceite:** música secreta + main quest de 3 passos jogáveis.

## R6 — Escala de conteúdo

**Entregáveis**
- Segundo mapa com 2 mecânicas únicas.
- Duas armas novas.
- Uma wonder weapon.
- Um inimigo especial.
- Teste “sem mudança no núcleo”.

**Aceite:** novo mapa/arma sem alterar o núcleo; validador e testes verdes.

## R7 — Produção

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
| Ferramenta antes da base | Médio | R4 só após R3 |
| Conteúdo inválido | Alto | Validador + CI |
| Performance em iGPU | Médio | Orçamento por mapa |
| Escopo crescer | Alto | Não-objetivos e Kanban |
