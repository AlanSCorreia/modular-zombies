# Roadmap — v2

**Estratégia:** reescrever o runtime em paralelo; a v1 fica arquivada como
referência/rollback. O board operacional é `../../KANBAN.md`.

**Regra:** uma fase ativa por vez; não avançar sem o aceite da anterior.

## Visão geral

| Fase | Nome | Objetivo | Status | Tamanho |
|---|---|---|---|---|
| R0 | Preparação | Arquivar v1, scaffold v2, docs e Kanban | **Parcial** | S |
| R1 | Core + conteúdo | Definições, registry, validador, Bunker 13 em dados | Backlog | M |
| R2 | Loop de gameplay | Player, armas, zumbis, rodadas, economia, efeitos | Backlog | L |
| R3 | Interações/UI/áudio | Portas, compras, caixa, perks, HUD, menus, som | Backlog | M |
| R4 | Ferramentas de mapa | Criar/validar/testar mapas no editor | Backlog | M |
| R5 | Quests/Easter Eggs | QuestSystem, música, mecânica única, debug | Backlog | L |
| R6 | Escala de conteúdo | 2º mapa, armas novas, wonder weapon, inimigo | Backlog | L |
| R7 | Produção | Save, settings, export, pools, CI, performance | Backlog | L |

## R0 — Preparação (parcial)

**Entregáveis**
- v1 arquivada em `zombie-fps-legacy`.
- v2 criada, assets copiados.
- Scaffold: `project.godot`, `main.tscn`, `Events`, `Content`.
- Docs de planejamento atualizados + Kanban.
- `README.md` da v2.
- Árvore híbrida definida: `content/` JSON, `assets/` binários, `source/` Blender.

**Pendências para fechar R0**
- Criar `src/audio/sfx.gd`, `src/gameplay/game_root.gd` e plugin placeholder.
- Validar importação no Godot.
- Aprovar escopo R1–R7.

**Aceite:** projeto abre/importa sem erro; docs, árvore de assets e Kanban aprovados.

## R1 — Core + conteúdo

**Entregáveis**
- `MapDefinition`, `DoorDefinition`, `WallBuyDefinition`, `SpawnDefinition`,
  `BoxDefinition`, `PerkDefinition`, `MechanicDefinition`.
- `WeaponDefinition`, `EnemyDefinition`, `QuestDefinition`, `QuestStep`,
  `RewardDefinition`.
- `ContentRegistry` com varredura e IDs.
- `ContentValidator` (referências, IDs, ciclos).
- `Bunker13Builder` lendo `MapDefinition`.
- JSON do Bunker 13, das 5 armas, da faca e dos explosivos.
- Pipeline Blender de armas/mãos + `GripSocket` por classe.
- JSON schema/loader/validator (schema_version, IDs e referências).
- Assets reorganizados em `assets/` e fontes em `source/`; paths validados.
- Testes de definições e validação.

**Aceite:** Bunker 13 carrega 100% por JSON; validador 0 erros; 0 refs de
asset quebradas; nenhum `if map_id` no núcleo e nenhum conteúdo em `.tres`.

## R2 — Loop de gameplay

**Entregáveis**
- `PlayerController` (movimento, vida, câmera, interação).
- `WeaponController` (2 slots, tiro, recarga, troca).
- `ExplosionSystem`, granadas, lança-foguete e barris explosivos.
- `MeleeController` + faca (V, corte diagonal, cooldown e lunge).
- `ViewmodelFactory` (armas GLB + mãos compartilhadas + animações).
- `ZombieEnemy` com `EnemyDefinition` e animação `Climb`.
- `RoundManager` (estado, spawn, escalonamento).
- `Economy` (pontos, compra, bônus).
- `Effects` (sangue, decais, tracers, cápsulas).
- Teste integrado do loop.

**Aceite:** Bunker 13 jogável do início ao game over; todas as armas usam
`WeaponDefinition` (JSON) e o mesmo `HandsRig`; faca e explosivos funcionando.

## R3 — Interações, UI e áudio

**Entregáveis**
- `InteractionSystem` tipado (`Interactable`).
- Portas, wallbuys, caixa e perks.
- Traps explosivas e props explosivos vindos do JSON do mapa.
- HUD, menu, pause, game over.
- Áudio 2D/3D, música, mixagem e VFX de explosão/faca.
- HUD de equipamento (granadas).
- Prompts, hitmarker, vinheta e feedback de pontos.
- Teste de interação e UI.

**Aceite:** paridade funcional com a v1 + explosivos/faca (checklist).

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
| Paridade | Checklist v1 → v2 antes da troca de launcher |

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
