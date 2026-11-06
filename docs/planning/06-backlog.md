# Backlog — v2

Legenda: **P0** bloqueante, **P1** próxima entrega, **P2** depois.  
Este backlog é estratégico; o status real fica no `KANBAN.md`.

> **P0 entregue:** R0 completo. **R1 concluído:** loader/validador, 2 mapas,
> 5 armas, Bunker 13 JSON + builder, models reorganizados e testes.
> R2 em andamento (slice já jogável).

## R0 — Preparação

| ID | Tarefa | Pri |
|---|---|---|
| R0.1 | Arquivar v1 | P0 |
| R0.2 | Criar v2 e copiar assets | P0 |
| R0.3 | Scaffold `project.godot`/`main.tscn` | P0 |
| R0.4 | `Events` + `ContentRegistry` | P0 |
| R0.5 | Criar `Sfx` e `game_root` mínimos | P0 |
| R0.6 | Validar importação no Godot | P0 |
| R0.7 | Docs v2 + Kanban | P0 |
| R0.8 | Árvore de assets (`assets/`, `source/`, `content/`, `schemas/`) | P0 |
| R0.10 | Launcher do editor | P1 |
| R0.11 | Git + `.gitignore` + commit inicial | P0 |
| R0.12 | CI local (`tests/ci.sh`) | P0 |
| R0.13 | Vertical slice jogável | P0 |
| R0.14 | Bench + orçamento de performance | P0 |

## R1 — Core + conteúdo JSON

| ID | Tarefa | Pri |
|---|---|---|
| R1.1 | JSON schemas (map, weapon, enemy, perk, quest, explosive, melee) | P0 |
| R1.2 | `ContentRegistry` + loader JSON + IDs | P0 |
| R1.3 | `ContentValidator` (schema, referências, ciclos) | P0 |
| R1.4 | DTOs tipados (`MapDefinition`, `WeaponDefinition`, `ExplosiveDefinition`, `MeleeDefinition`) | P0 |
| R1.5 | `Bunker13Builder` lendo `MapDefinition` | P0 |
| R1.6 | Converter Bunker 13 + 5 armas para JSON | P0 |
| R1.9 | Validação de assets (paths/importação) | P0 |
| R1.10 | Testes de schema/validação | P0 |
| R1.11 | Reorganizar assets e mover `.blend` para `source/` | P0 |
| R1.12 | Template de arma + schema completo | P0 |

## R2 — Loop de gameplay

| ID | Tarefa | Pri |
|---|---|---|
| R2.1 | `PlayerController` | P0 |
| R2.2 | `WeaponController` (hitscan/projectile/melee) | P0 |
| R2.3 | `ViewmodelFactory` (armas GLB + mãos compartilhadas) | P0 |
| R2.4 | `HandsRig` + cache + `grip_profile` | P0 |
| R2.5 | `ZombieEnemy` + `EnemyDefinition` | P0 |
| R2.6 | `RoundManager` | P0 |
| R2.7 | `Economy` | P0 |
| R2.8 | `Effects` (sangue, decais, tracers, cápsulas) | P0 |
| R2.9 | `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia) | P0 |
| R2.10 | Granada equipável (G) | P0 |
| R2.11 | Lança-foguete (`projectile`) | P0 |
| R2.12 | Barris explosivos ao receber tiro | P0 |
| R2.13 | `MeleeController` (V, corte diagonal, lunge, cooldown) | P0 |
| R2.14 | Faca GLB + mãos compartilhadas + animação `knife_slash` | P0 |
| R2.17 | `Barricade` + estado das tábuas | P0 |
| R2.18 | `BarricadeSystem` + hold F + pontos | P0 |
| R2.19 | IA de zumbi: arrancar, entrar e fila por janela | P0 |
| R2.20 | Testes de barricada (reparo, interrupção, breach) | P0 |
| R2.21 | Validar workflow com uma segunda arma | P0 |
| R2.22 | JSON de faca, granada, foguete, barris e traps | P0 |
| R2.23 | Mãos separadas (`hands.glb`) + `GripSocket` | P0 |
| R2.24 | Bunker 13 jogável (spawns, portas, barricadas) | P0 |
| R2.25 | `--map <id>` no GameRoot | P0 |
| R2.26 | Teste visual do Bunker 13 | P1 |
| R2.27 | Extrair `BoxBuilder`/helpers comuns | P1 |
| R2.28 | Versionar `.blend` fonte em `source/blender` | P1 |
| R2.15 | Testes de explosivos e faca | P0 |
| R2.16 | Teste integrado do loop | P0 |

## R3 — Interações/UI/áudio

| ID | Tarefa | Pri |
|---|---|---|
| R3.1 | `InteractionSystem` tipado | P0 |
| R3.2 | Portas e wallbuys | P0 |
| R3.3 | Caixa e perks | P0 |
| R3.4 | Traps explosivas | P0 |
| R3.5 | Props explosivos no JSON do mapa | P0 |
| R3.6 | HUD/menu/pause/game over | P0 |
| R3.7 | HUD de equipamento (granadas) | P1 |
| R3.8 | Áudio/VFX de explosão, faca e barricada | P0 |
| R3.11 | HUD de progresso de reparo de barricada | P1 |
| R3.9 | Prompts/hitmarker/vinheta | P1 |
| R3.10 | Testes de interação/UI/combate | P0 |

## R4 — Ferramentas de mapa

| ID | Tarefa | Pri |
|---|---|---|
| R4.1 | Plugin `bunker_tools` + dock | P0 |
| R4.2 | Criar/duplicar mapa | P0 |
| R4.3 | Validador no dock | P0 |
| R4.4 | Playtest por mapa | P0 |
| R4.5 | Templates | P1 |
| R4.6 | Marcadores 3D com gizmos | P1 |
| R4.7 | Content browser | P2 |
| R4.8 | Documentação do autor | P1 |

## R5 — Quests/Easter Eggs

| ID | Tarefa | Pri |
|---|---|---|
| R5.1 | `QuestSystem` + EventBus | P0 |
| R5.2 | Triggers base | P0 |
| R5.3 | Recompensas | P0 |
| R5.4 | 3 rádios no Bunker 13 | P0 |
| R5.5 | `Bunker13PowerMechanic` | P1 |
| R5.6 | Validador de grafo/softlock | P0 |
| R5.7 | Debug overlay | P1 |
| R5.8 | Grafo visual (GraphEdit) | P2 |

## R6 — Escala

| ID | Tarefa | Pri |
|---|---|---|
| R6.1 | Segundo mapa | P0 |
| R6.2 | Duas armas novas | P0 |
| R6.3 | Wonder weapon | P1 |
| R6.4 | Inimigo especial | P1 |
| R6.5 | Teste sem mudança no núcleo | P0 |

## R7 — Produção

| ID | Tarefa | Pri |
|---|---|---|
| R7.1 | Save/load versionado | P0 |
| R7.2 | Settings | P1 |
| R7.3 | Exportação Linux + smoke | P0 |
| R7.4 | Pool de áudio/efeitos | P1 |
| R7.5 | Navmesh pré-bakeada | P1 |
| R7.6 | CI + validador | P0 |
| R7.7 | Soak test 30 min | P1 |
| R7.8 | Auditoria de licenças/assets | P1 |
| R7.9 | Save/load do estado das barricadas | P1 |
| R7.10 | Checklist de release | P1 |
