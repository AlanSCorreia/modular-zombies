# Backlog — v2

Legenda: **P0** bloqueante, **P1** próxima entrega, **P2** depois.  
Este backlog é estratégico; o status real fica no `KANBAN.md`.

> **Etapas 1 e 2 concluídas:** loader/validador, 2 mapas,
> 5 armas, Bunker 13 JSON + builder, models reorganizados e testes.
> Etapa 3 — Gameplay em andamento (slice já jogável).

## Etapa 1 — Preparação

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA1.1 | Arquivar v1 | P0 |
| ETAPA1.2 | Criar v2 e copiar assets | P0 |
| ETAPA1.3 | Scaffold `project.godot`/`main.tscn` | P0 |
| ETAPA1.4 | `Events` + `ContentRegistry` | P0 |
| ETAPA1.5 | Criar `Sfx` e `game_root` mínimos | P0 |
| ETAPA1.6 | Validar importação no Godot | P0 |
| ETAPA1.7 | Docs v2 + Kanban | P0 |
| ETAPA1.8 | Árvore de assets (`assets/`, `source/`, `content/`, `schemas/`) | P0 |
| ETAPA1.10 | Launcher do editor | P1 |
| ETAPA1.11 | Git + `.gitignore` + commit inicial | P0 |
| ETAPA1.12 | CI local (`tests/ci.sh`) | P0 |
| ETAPA1.13 | Vertical slice jogável | P0 |
| ETAPA1.14 | Bench + orçamento de performance | P0 |

## Etapa 2 — Conteúdo JSON

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA2.1 | JSON schemas (map, weapon, enemy, perk, quest, explosive, melee) | P0 |
| ETAPA2.2 | `ContentRegistry` + loader JSON + IDs | P0 |
| ETAPA2.3 | `ContentValidator` (schema, referências, ciclos) | P0 |
| ETAPA2.4 | DTOs tipados (`MapDefinition`, `WeaponDefinition`, `ExplosiveDefinition`, `MeleeDefinition`) | P0 |
| ETAPA2.5 | `Bunker13Builder` lendo `MapDefinition` | P0 |
| ETAPA2.6 | Converter Bunker 13 + 5 armas para JSON | P0 |
| ETAPA2.9 | Validação de assets (paths/importação) | P0 |
| ETAPA2.10 | Testes de schema/validação | P0 |
| ETAPA2.11 | Reorganizar assets e mover `.blend` para `source/` | P0 |
| ETAPA2.12 | Template de arma + schema completo | P0 |

## Etapa 3 — Gameplay

> Atendido: ETAPA3.34–36 (geometria autoral). A Etapa 4 só começa depois do
> aceite da Etapa 3.
> Ordem de execução: ETAPA3.40 (softlock, issue #3) concluída; agora ETAPA3.38
> (`MapContext`/`Interactable`, issue #4) e, em seguida, ETAPA3.41 (extrair o
> harness de `GameRoot` para `tests/`).

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA3.1 | `PlayerController` | P0 |
| ETAPA3.2 | `WeaponController` (hitscan/projectile/melee) | P0 |
| ETAPA3.3 | `ViewmodelFactory` (armas GLB + mãos compartilhadas) | P0 |
| ETAPA3.4 | `HandsRig` + cache + `grip_profile` | P0 |
| ETAPA3.5 | `ZombieEnemy` + `EnemyDefinition` | P0 |
| ETAPA3.6 | `RoundManager` | P0 |
| ETAPA3.7 | `Economy` | P0 |
| ETAPA3.8 | `Effects` (sangue, decais, tracers, cápsulas) | P0 |
| ETAPA3.9 | `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia) | P0 |
| ETAPA3.10 | Granada equipável (G) | P0 |
| ETAPA3.11 | Lança-foguete (`projectile`) | P0 |
| ETAPA3.12 | Barris explosivos ao receber tiro | P0 |
| ETAPA3.13 | `MeleeController` (V, corte diagonal, lunge, cooldown) | P0 |
| ETAPA3.14 | Faca GLB + mãos compartilhadas + animação `knife_slash` | P0 |
| ETAPA3.17 | `Barricade` + estado das tábuas | P0 |
| ETAPA3.18 | `BarricadeSystem` + hold F + pontos | P0 |
| ETAPA3.19 | IA de zumbi: arrancar, entrar e fila por janela | P0 |
| ETAPA3.20 | Testes de barricada (reparo, interrupção, breach) | P0 |
| ETAPA3.21 | Validar workflow com uma segunda arma | P0 |
| ETAPA3.22 | JSON de faca, granada, foguete, barris e traps | P0 |
| ETAPA3.23 | Mãos separadas (`hands.glb`) + `GripSocket` | P0 |
| ETAPA3.24 | Bunker 13 jogável (spawns, portas, barricadas) | P0 |
| ETAPA3.25 | `--map <id>` no GameRoot | P0 |
| ETAPA3.26 | Teste visual do Bunker 13 | P1 |
| ETAPA3.27 | Extrair `BoxBuilder`/helpers comuns | P1 |
| ETAPA3.28 | Versionar `.blend` fonte em `source/blender` (feito) | P1 |
| ETAPA3.29 | `InteractionSystem` genérico (porta/wallbuy/perk/caixa/barricada) | P0 |
| ETAPA3.30 | Abrir vãos de janela + reposicionar barricadas | P0 |
| ETAPA3.31 | Spawns vinculados a `barricade.spawn_position` | P0 |
| ETAPA3.32 | Corrigir falsos positivos do teste integrado | P0 |
| ETAPA3.33 | Reforçar `ContentValidator` (schema, IDs, hands, áudio) | P1 |
| ETAPA3.34 | Migrar geometria do mapa para cena autoral (GLB/`.tscn`) (feito) | P0 |
| ETAPA3.35 | Separar âncoras/interactables da geometria (feito) | P0 |
| ETAPA3.36 | Exportar GLB do mapa e carregar no Godot (feito) | P0 |
| ETAPA3.37 | Teste que impede geração de modelo 3D em runtime (feito) | P1 |
| ETAPA3.38 | `MapContext` tipado + `Interactable` (porta/barricada) (feito) | P0 |
| ETAPA3.39 | `WeaponSlots` + `ViewmodelFactory` (slots feitos; factory/mãos pendentes) | P0 |
| ETAPA3.40 | Corrigir softlock do Bunker 13 + spawns/navmesh alcançáveis (feito) | P0 |
| ETAPA3.41 | Extrair harness de teste do `GameRoot` para `tests/` | P1 |
| ETAPA3.42 | Pool/cache de tracers, áudio e animações | P1 |
| ETAPA3.43 | HUD em `.tscn` | P1 |
| ETAPA3.44 | `RoundManager`/`Economy` fora do `GameRoot` | P1 |
| ETAPA3.45 | InputMap + validação de áudio/partes no validador | P2 |
| ETAPA3.46 | Bench com draw calls/frame time e baseline atualizado | P2 |
| ETAPA3.15 | Testes de explosivos e faca | P0 |
| ETAPA3.16 | Teste integrado do loop | P0 |

## Etapa 4 — Interações

> Inicia após o aceite da Etapa 3.

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA4.1 | `InteractionSystem` tipado | P0 |
| ETAPA4.2 | Portas e wallbuys | P0 |
| ETAPA4.3 | Caixa e perks | P0 |
| ETAPA4.4 | Traps explosivas | P0 |
| ETAPA4.5 | Props explosivos no JSON do mapa | P0 |
| ETAPA4.6 | HUD/menu/pause/game over | P0 |
| ETAPA4.7 | HUD de equipamento (granadas) | P1 |
| ETAPA4.8 | Áudio/VFX de explosão, faca e barricada | P0 |
| ETAPA4.11 | HUD de progresso de reparo de barricada | P1 |
| ETAPA4.9 | Prompts/hitmarker/vinheta | P1 |
| ETAPA4.10 | Testes de interação/UI/combate | P0 |

## Etapa 5 — Ferramentas de mapa

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA5.1 | Plugin `bunker_tools` + dock | P0 |
| ETAPA5.2 | Criar/duplicar mapa | P0 |
| ETAPA5.3 | Validador no dock | P0 |
| ETAPA5.4 | Playtest por mapa | P0 |
| ETAPA5.5 | Templates | P1 |
| ETAPA5.6 | Marcadores 3D com gizmos | P1 |
| ETAPA5.7 | Content browser | P2 |
| ETAPA5.8 | Documentação do autor | P1 |

## Etapa 6 — Quests e Easter Eggs

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA6.1 | `QuestSystem` + EventBus | P0 |
| ETAPA6.2 | Triggers base | P0 |
| ETAPA6.3 | Recompensas | P0 |
| ETAPA6.4 | 3 rádios no Bunker 13 | P0 |
| ETAPA6.5 | `Bunker13PowerMechanic` | P1 |
| ETAPA6.6 | Validador de grafo/softlock | P0 |
| ETAPA6.7 | Debug overlay | P1 |
| ETAPA6.8 | Grafo visual (GraphEdit) | P2 |

## Etapa 7 — Escala de conteúdo

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA7.1 | Segundo mapa | P0 |
| ETAPA7.2 | Duas armas novas | P0 |
| ETAPA7.3 | Wonder weapon | P1 |
| ETAPA7.4 | Inimigo especial | P1 |
| ETAPA7.5 | Teste sem mudança no núcleo | P0 |

## Etapa 8 — Produção

| ID | Tarefa | Pri |
|---|---|---|
| ETAPA8.1 | Save/load versionado | P0 |
| ETAPA8.2 | Settings | P1 |
| ETAPA8.3 | Exportação Linux + smoke | P0 |
| ETAPA8.4 | Pool de áudio/efeitos | P1 |
| ETAPA8.5 | Navmesh pré-bakeada | P1 |
| ETAPA8.6 | CI + validador | P0 |
| ETAPA8.7 | Soak test 30 min | P1 |
| ETAPA8.8 | Auditoria de licenças/assets | P1 |
| ETAPA8.9 | Save/load do estado das barricadas | P1 |
| ETAPA8.10 | Checklist de release | P1 |
