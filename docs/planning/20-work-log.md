---
kind: log
area: execution
status: active
stage: 4
owner: docs
last_reviewed: 2026-11-08
---

# Work log — Etapa 4

Registro curto da etapa ativa, **mais recente primeiro**. A Etapa 3 detalhada
está em
[`archive/20-work-log-2026-11-etapa3.md`](archive/20-work-log-2026-11-etapa3.md);
o início do projeto, em
[`archive/20-work-log-2026-11-detalhado.md`](archive/20-work-log-2026-11-detalhado.md).

## 2026-11-08 — Inimigo especial Brute (issue #36)

- Asset `brute.blend`/GLB (variante do zumbi) e `enemy.brute` com mais vida,
  dano e escala.
- `SpecialEnemyData`/`special_enemies` no mapa/schema/validador.
- `RoundManager` sorteia o especial por rodada/chance; `GameRoot` instancia o
  `EnemyData` escolhido.
- `starting_weapon` saiu do `GameRoot` e virou campo do mapa.
- Testes `ENEMY_OK` e `NO_CORE_OK`; Etapa 7 aceita com tag `etapa7`.
- Próxima: Etapa 8 (save/load).

## 2026-11-08 — Wonder weapon Ray Gun (issue #35)

- Asset autoral `raygun.blend`/GLB com corpo, cano, coils emissivos e sockets.
- `weapon.raygun` projectile/explosive, shared hands e áudio `gun_raygun`.
- Fica disponível na caixa (pool de armas) sem código especial.
- Teste `WONDER_OK` cobre equipar, tiro, explosão, FX e recarga.
- Próximo: inimigo especial Brute (#36).

## 2026-11-08 — Duas armas novas (issue #34)

- `weapon.pistol`: GLB normalizado de mm para metros, orientado, com
  `GripSocket`/`Muzzle`.
- `weapon.sks`: asset autoral com stock, cano, magazine, bolt e trigger.
- JSON/schema/validador e shared hands; SKS no wallbuy do Depot.
- SFX `gun_sks`; `WEAPONS_OK` cobre compra, tiro e recarga das duas.
- Próximo: wonder weapon (#35).

## 2026-11-08 — Segundo mapa jogável (issue #33)

- `map.depot`: 2 salas, porta, wallbuy, spawns e luzes, com cena autoral
  `depot.blend`/GLB.
- Mecânicas reutilizadas: PowerMechanic (`power_depot`) e rádio
  (`radio_depot`) com quest `quest.depot_signal`.
- `--map map.depot` abre e é jogável; validador e loader aceitam 3 mapas e 4
  quests.
- Teste `SECOND_MAP_OK` cobre mapa, energia, porta, rádio e recompensa.
- Próximo: duas armas novas (#34).

## 2026-11-08 — Main quest de 3 passos (issue #32)

- `quest.bunker13_main`: energia → rádio → entrar no setor C, com 1000 pontos.
- Passos fora de ordem são ignorados; conclusão usa banner/eventos.
- Teste `MAIN_QUEST_OK` cobre ordem, 3 passos e recompensa.
- Etapa 6 aceita com tag `etapa6`; próxima é a Etapa 7 (segundo mapa).

## 2026-11-08 — QuestValidator (issue #31)

- `QuestValidator` valida IDs, triggers, rewards, referências de alvo, `next`
  inexistente, passos órfãos e ciclos.
- `ContentValidator` delega a validação de quests; erros trazem contexto.
- Teste `QUEST_VALIDATOR_OK` cobre quest válida, ciclo, órfão, next e reward.
- Próximo: main quest de 3 passos (#32).

## 2026-11-08 — PowerMechanic do Bunker 13 (issue #30)

- Asset autoral `power_switch.blend`/GLB; `PowerSwitchData`/`State` no
  JSON/schema/validador.
- Interruptor no setor B: liga luzes de energia, abre `door2` sem custo e emite
  `Events.power_on`.
- Quest `quest.bunker13_power` usa trigger `power`; recompensa 300 pontos.
- Teste `POWER_OK` cobre luzes, porta, quest e idempotência.
- Próximo: validador de quests (#31).

## 2026-11-08 — Rádios no Bunker 13 (issue #29)

- Asset autoral `radio.blend`/GLB; `RadioData`/`RadioState` e `radios` no
  JSON/schema/validador.
- `MapSceneBuilder` cria holder, área interativa e label; `PlayerController`
  mostra prompt de sintonia.
- `GameRoot` marca rádio usado, toca SFX e emite banner; quest recebe os 3
  eventos e paga pontos + música.
- Teste `RADIO_OK` cobre 3 rádios, uso único, quest e recompensa.
- Próximo: `Bunker13PowerMechanic` (#30).

## 2026-11-08 — QuestSystem + DTOs/triggers/recompensas (issue #28)

- `QuestData`/`QuestStepData`/`RewardData`, schema e
  `content/quests/bunker13_music.json`.
- `QuestSystem` executa passos em sequência (interact/kill/enter_area/collect),
  ignora eventos fora de ordem e emite progresso/recompensa.
- `GameRoot` aplica recompensas de pontos, música, arma e perk.
- Teste `QUEST_OK` cobre passo pulado, 3 passos e 500 pontos + música.
- Próximo: 3 rádios no Bunker 13 (#29).

## 2026-11-08 — Documentação do autor (issue #27)

- `23-map-author-quickstart.md`: criar/duplicar, trocar cena GLB, preencher
  JSON, validar, playtest e erros comuns.
- Link no índice do planning, em `04-map-authoring-tools.md` e no README do
  template.
- `DOCS_OK` verde; Etapa 5 aceita com tag `etapa5`.
- Próxima etapa: Quests (#28).

## 2026-11-08 — Playtest por mapa (issue #26)

- Botão “Playtest mapa” no dock usa o mapa selecionado.
- `MapArgs` ganhou override one-shot em `user://playtest.cfg`; `--map` tem
  prioridade e o override é consumido na primeira leitura.
- Teste `PLAYTEST_OK` cobre precedência e one-shot; CI verde.
- Próximo: documentação do autor (#27).

## 2026-11-08 — Criar/duplicar mapa no bunker_tools (issue #25)

- `MapTools` headless: create a partir de `templates/map/template.json` e
  duplicate de mapa existente, com bloqueio de overwrite.
- Dock ganhou campos de id/nome e botões “Novo (template)” e “Duplicar
  selecionado”; validação roda após a operação.
- Template `templates/map/template.json` + README, usando a cena do slice até
  o autor exportar geometria própria.
- Teste `TOOLS_OK` cobre create, duplicate e overwrite; CI verde.
- Próximo: playtest por mapa (#26).

## 2026-11-08 — Áudio 2D/3D, música e mixagem (issue #24)

- Buses `Music`/`Weapons`/`Zombies`/`UI`/`Foley` criados no `Sfx`; roteamento
  por categoria em `play`/`play_3d`.
- Master volume no pause com slider e persistência em `user://audio.cfg`.
- Stingers de início/fim de rodada na bus Music.
- Teste `AUDIO_OK` cobre buses, chaves e volume; Etapa 4 aceita.
- Próxima etapa: ferramentas de mapa (#25).

## 2026-11-08 — VFX/SFX + HUD de granadas (issue #23)

- Explosão com partículas/luz em `ExplosionSystem` (mesh/material cacheados) e
  som de explosão via pool do `Sfx`.
- SFX para faca, quebra/reparo de barricada e arremesso de granada.
- HUD ganhou contador `GRANADAS N`, ligado a `grenades_changed`.
- Teste `FX_OK` cobre contador, FX de explosão e chaves de áudio.
- Issue #23 fechada; próximo é áudio/mixagem (#24).

## 2026-11-08 — Traps explosivas (issue #22)

- `TrapData`, `map.traps`, schema/validador e `MapContext.traps`.
- `ExplosiveTrap` com área 2|4, corpo 16, `hit()`/`detonate()` e cadeia.
- Asset autoral `trap.blend`/GLB; 2 traps no Bunker 13.
- Teste `TRAP_OK`; Etapa 4 iniciada.

**Próximo item:** save/load versionado da run (issue #37); depois settings,
exportação Linux e performance.
