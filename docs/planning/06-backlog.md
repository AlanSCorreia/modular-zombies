# Backlog — v2

Legenda: **P0** bloqueante, **P1** próxima entrega, **P2** depois.  
Este backlog é estratégico; o status real fica no `KANBAN.md`.

> **Preparação e Conteúdo concluídos:** loader/validador, 2 mapas,
> 5 armas, Bunker 13 JSON + builder, models reorganizados e testes.
> Gameplay em andamento (slice já jogável).

## Preparação

| ID | Tarefa | Pri |
|---|---|---|
| PREP.1 | Arquivar v1 | P0 |
| PREP.2 | Criar v2 e copiar assets | P0 |
| PREP.3 | Scaffold `project.godot`/`main.tscn` | P0 |
| PREP.4 | `Events` + `ContentRegistry` | P0 |
| PREP.5 | Criar `Sfx` e `game_root` mínimos | P0 |
| PREP.6 | Validar importação no Godot | P0 |
| PREP.7 | Docs v2 + Kanban | P0 |
| PREP.8 | Árvore de assets (`assets/`, `source/`, `content/`, `schemas/`) | P0 |
| PREP.10 | Launcher do editor | P1 |
| PREP.11 | Git + `.gitignore` + commit inicial | P0 |
| PREP.12 | CI local (`tests/ci.sh`) | P0 |
| PREP.13 | Vertical slice jogável | P0 |
| PREP.14 | Bench + orçamento de performance | P0 |

## Conteúdo JSON

| ID | Tarefa | Pri |
|---|---|---|
| CONTENT.1 | JSON schemas (map, weapon, enemy, perk, quest, explosive, melee) | P0 |
| CONTENT.2 | `ContentRegistry` + loader JSON + IDs | P0 |
| CONTENT.3 | `ContentValidator` (schema, referências, ciclos) | P0 |
| CONTENT.4 | DTOs tipados (`MapDefinition`, `WeaponDefinition`, `ExplosiveDefinition`, `MeleeDefinition`) | P0 |
| CONTENT.5 | `Bunker13Builder` lendo `MapDefinition` | P0 |
| CONTENT.6 | Converter Bunker 13 + 5 armas para JSON | P0 |
| CONTENT.9 | Validação de assets (paths/importação) | P0 |
| CONTENT.10 | Testes de schema/validação | P0 |
| CONTENT.11 | Reorganizar assets e mover `.blend` para `source/` | P0 |
| CONTENT.12 | Template de arma + schema completo | P0 |

## Gameplay

| ID | Tarefa | Pri |
|---|---|---|
| GAMEPLAY.1 | `PlayerController` | P0 |
| GAMEPLAY.2 | `WeaponController` (hitscan/projectile/melee) | P0 |
| GAMEPLAY.3 | `ViewmodelFactory` (armas GLB + mãos compartilhadas) | P0 |
| GAMEPLAY.4 | `HandsRig` + cache + `grip_profile` | P0 |
| GAMEPLAY.5 | `ZombieEnemy` + `EnemyDefinition` | P0 |
| GAMEPLAY.6 | `RoundManager` | P0 |
| GAMEPLAY.7 | `Economy` | P0 |
| GAMEPLAY.8 | `Effects` (sangue, decais, tracers, cápsulas) | P0 |
| GAMEPLAY.9 | `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia) | P0 |
| GAMEPLAY.10 | Granada equipável (G) | P0 |
| GAMEPLAY.11 | Lança-foguete (`projectile`) | P0 |
| GAMEPLAY.12 | Barris explosivos ao receber tiro | P0 |
| GAMEPLAY.13 | `MeleeController` (V, corte diagonal, lunge, cooldown) | P0 |
| GAMEPLAY.14 | Faca GLB + mãos compartilhadas + animação `knife_slash` | P0 |
| GAMEPLAY.17 | `Barricade` + estado das tábuas | P0 |
| GAMEPLAY.18 | `BarricadeSystem` + hold F + pontos | P0 |
| GAMEPLAY.19 | IA de zumbi: arrancar, entrar e fila por janela | P0 |
| GAMEPLAY.20 | Testes de barricada (reparo, interrupção, breach) | P0 |
| GAMEPLAY.21 | Validar workflow com uma segunda arma | P0 |
| GAMEPLAY.22 | JSON de faca, granada, foguete, barris e traps | P0 |
| GAMEPLAY.23 | Mãos separadas (`hands.glb`) + `GripSocket` | P0 |
| GAMEPLAY.24 | Bunker 13 jogável (spawns, portas, barricadas) | P0 |
| GAMEPLAY.25 | `--map <id>` no GameRoot | P0 |
| GAMEPLAY.26 | Teste visual do Bunker 13 | P1 |
| GAMEPLAY.27 | Extrair `BoxBuilder`/helpers comuns | P1 |
| GAMEPLAY.28 | Versionar `.blend` fonte em `source/blender` | P1 |
| GAMEPLAY.29 | `InteractionSystem` genérico (porta/wallbuy/perk/caixa/barricada) | P0 |
| GAMEPLAY.30 | Abrir vãos de janela + reposicionar barricadas | P0 |
| GAMEPLAY.31 | Spawns vinculados a `barricade.spawn_position` | P0 |
| GAMEPLAY.32 | Corrigir falsos positivos do teste integrado | P0 |
| GAMEPLAY.33 | Reforçar `ContentValidator` (schema, IDs, hands, áudio) | P1 |
| GAMEPLAY.15 | Testes de explosivos e faca | P0 |
| GAMEPLAY.16 | Teste integrado do loop | P0 |

## Interações

| ID | Tarefa | Pri |
|---|---|---|
| INTERACT.1 | `InteractionSystem` tipado | P0 |
| INTERACT.2 | Portas e wallbuys | P0 |
| INTERACT.3 | Caixa e perks | P0 |
| INTERACT.4 | Traps explosivas | P0 |
| INTERACT.5 | Props explosivos no JSON do mapa | P0 |
| INTERACT.6 | HUD/menu/pause/game over | P0 |
| INTERACT.7 | HUD de equipamento (granadas) | P1 |
| INTERACT.8 | Áudio/VFX de explosão, faca e barricada | P0 |
| INTERACT.11 | HUD de progresso de reparo de barricada | P1 |
| INTERACT.9 | Prompts/hitmarker/vinheta | P1 |
| INTERACT.10 | Testes de interação/UI/combate | P0 |

## Ferramentas de mapa

| ID | Tarefa | Pri |
|---|---|---|
| TOOLS.1 | Plugin `bunker_tools` + dock | P0 |
| TOOLS.2 | Criar/duplicar mapa | P0 |
| TOOLS.3 | Validador no dock | P0 |
| TOOLS.4 | Playtest por mapa | P0 |
| TOOLS.5 | Templates | P1 |
| TOOLS.6 | Marcadores 3D com gizmos | P1 |
| TOOLS.7 | Content browser | P2 |
| TOOLS.8 | Documentação do autor | P1 |

## Quests e Easter Eggs

| ID | Tarefa | Pri |
|---|---|---|
| QUESTS.1 | `QuestSystem` + EventBus | P0 |
| QUESTS.2 | Triggers base | P0 |
| QUESTS.3 | Recompensas | P0 |
| QUESTS.4 | 3 rádios no Bunker 13 | P0 |
| QUESTS.5 | `Bunker13PowerMechanic` | P1 |
| QUESTS.6 | Validador de grafo/softlock | P0 |
| QUESTS.7 | Debug overlay | P1 |
| QUESTS.8 | Grafo visual (GraphEdit) | P2 |

## Escala de conteúdo

| ID | Tarefa | Pri |
|---|---|---|
| SCALE.1 | Segundo mapa | P0 |
| SCALE.2 | Duas armas novas | P0 |
| SCALE.3 | Wonder weapon | P1 |
| SCALE.4 | Inimigo especial | P1 |
| SCALE.5 | Teste sem mudança no núcleo | P0 |

## Produção

| ID | Tarefa | Pri |
|---|---|---|
| PROD.1 | Save/load versionado | P0 |
| PROD.2 | Settings | P1 |
| PROD.3 | Exportação Linux + smoke | P0 |
| PROD.4 | Pool de áudio/efeitos | P1 |
| PROD.5 | Navmesh pré-bakeada | P1 |
| PROD.6 | CI + validador | P0 |
| PROD.7 | Soak test 30 min | P1 |
| PROD.8 | Auditoria de licenças/assets | P1 |
| PROD.9 | Save/load do estado das barricadas | P1 |
| PROD.10 | Checklist de release | P1 |
