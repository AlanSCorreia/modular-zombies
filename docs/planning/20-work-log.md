# Work log

Registro cronológico curto do que foi feito, testes e commits. O plano vivo
continua em `05-roadmap.md`, `06-backlog.md` e `KANBAN.md`.

## 2026-11-06 — Pool/cache de áudio, tracer e animação (issue #6)

**Feito**
- `Sfx` (`src/audio/sfx.gd`): pools fixos de 12 `AudioStreamPlayer` e
  16 `AudioStreamPlayer3D`, com reuso por canal e sem `new()` por som.
- Tracer (`weapon_controller.gd`): `BoxMesh` unitário e material emissivo
  estáticos; escala por distância em vez de malha por tiro.
- `ZombieEnemy`: mapa nome→animação e estado atual (`_play` sem varredura por
  frame); `PackedScene` e strip de root motion cacheados por cena.
- Decisão registrada como D-019 em `19-decision-log.md`.

**Testes (2026-11-06, reexecutados nesta sincronização)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`, `CI_OK`.
- Bench windowed: antes 61 FPS / 16,69 ms / 83 draw calls / 66,8 MB; depois
  60 FPS / 16,57 ms / 83 draw calls / 67,0 MB — sem regressão; ganho é de
  alocação por tiro/som/spawn.
- Ruído não fatal conhecido: `ObjectDB instances leaked` e `resources still in
  use` no exit headless.

**Commits**
- `7396942` `perf: pool audio and cache tracer/animation assets`
- `6fec227` `docs: record pool and cache block`

**Estado do board**
- KANBAN: pool/cache apenas em **Done**; **Doing** vazio; topo de **Ready** =
  HUD em `.tscn` (issue #7); etapa ativa 3.
- GitHub: #6 fechada (`etapa:3`, `prio:P1`, `area:gameplay`, milestone Etapa 3);
  #7 aberta com as mesmas labels e milestone.

## 2026-11-06 — Harness de integração extraído (issue #5)

**Feito**
- `tests/test_runner.tscn` roda como cena principal e instancia `main.tscn`;
  casos via `--case slice|smoke|softlock|pause|interaction|slots|ui|shot|bench|mouse|pause_shot`.
- `GameRoot` perdeu os `_run_*`, o despacho por flags e ~250 linhas de harness;
  mantém apenas a API de jogo.
- CI e `bench.sh` passaram a usar a cena de teste; gates preservados.
- Decisão registrada como D-018 em `19-decision-log.md`.

**Testes (2026-11-06, reportado pelo bloco de execução)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`, `CI_OK`.
- O doc-keeper não reexecutou o CI nesta sincronização: o tool `shell` foi
  bloqueado por permissão (`Permission denied: shell`). Pendência de reverificação.
- Ruído não fatal conhecido: `ObjectDB instances leaked` e `resources still in
  use` no exit headless.

**Commits**
- `f03abc8` `refactor: extract integration harness from GameRoot`
- `aaef364` `docs: record harness extraction`

**Estado do board**
- KANBAN: harness apenas em **Done**; **Doing** vazio; topo de **Ready** =
  pool/cache de tracers/áudio/animações (issue #6); etapa ativa 3.
- GitHub: #5 fechada (`etapa:3`, `prio:P1`, `area:infra`, milestone Etapa 3);
  #6 aberta (`etapa:3`, `prio:P1`, `area:gameplay`, milestone Etapa 3).

## 2026-11-06 — `MapContext` tipado + `Interactable` (issue #4)

**Feito**
- `MapContext` tipado (`doors`/`wallbuys`/`perks`/`box`/`barricades`/`spawns`/`lights`).
- `Interactable` com enum `Kind`; `DoorState.open` é o único estado de porta.
- Removido `door_open` global e strings `"kind"` dos consumidores
  (`PlayerController`, `GameRoot`, `MapSceneBuilder`).
- `MapNav` recebe `Dictionary[String, DoorState]`.
- Decisão registrada como D-017 em `19-decision-log.md`.

**Testes (2026-11-06, rodados nesta sincronização)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`, `CI_OK`.
- Gates do bloco: `MAP_OK`, `INTERACT_OK`, `BUNKER13_OK`.
- Ruído não fatal mantido: `ObjectDB instances leaked` e `resources still in
  use` no exit headless.

**Commits**
- `031268a` `refactor: type map context and interactables`
- `1ed5b7e` `docs: record typed map context`

**Estado do board**
- KANBAN: item apenas em **Done**; **Doing** vazio; topo de **Ready** =
  extrair harness de `GameRoot` para `tests/` (issue #5); etapa ativa 3.
- GitHub: #4 fechada (`etapa:3`, `prio:P0`, `area:gameplay`, milestone Etapa 3);
  #5 aberta (`etapa:3`, `prio:P1`, `area:infra`, milestone Etapa 3).

## 2026-11-06 — Softlock do Bunker 13 fechado (issue #3)

**Feito**
- Ondas só em salas alcançáveis, respeitando `zombie_count` (3/3/2); `only_a`
  no teste confirma que nenhum spawn inalcançável é usado.
- `MapNav` (BFS de salas/portas) usado por `GameRoot._reachable_spawns`;
  zumbi segue waypoints e faz idle quando não há caminho, sem atravessar porta
  fechada (`closed_blocked`).
- Economia validada no teste: 8 kills → 980 pontos; `door1` (750) abre o
  caminho (`open_path`).
- Gate `SOFTLOCK_OK` adicionado ao `tests/ci.sh`.

**Testes (2026-11-06, rodados nesta sincronização)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`, `CI_OK`.
- `SOFTLOCK_TEST initial=3 only_a=true closed_blocked=true spawned=8
  points_before=980 complete=true open_path=true`.
- Ruído não fatal mantido: `ObjectDB instances leaked` e `resources still in
  use` no exit headless.

**Commits**
- `ce62eb5` `fix: prevent Bunker 13 softlock with reachable waves`
- `d61b2bd` `docs: record softlock fix and next MapContext`

**Estado do board**
- KANBAN: softlock apenas em **Done** (duplicata em Review/Test removida);
  **Doing** vazio; topo de **Ready** = `MapContext` tipado + `Interactable`
  (issue #4); depois extrair o harness (`ETAPA3.41`).
- GitHub: #3 fechada; #4 aberta com `etapa:3`, `prio:P0`, `area:gameplay` e
  milestone Etapa 3.

## 2026-11-06 — Etapa 3 (Gameplay) em andamento

**Feito**
- Revisão de base com 3 subagentes; achados em `17-baseline-review.md`.
- Harness do Bunker 13 passou a falhar de verdade (`quit(1)`).
- Nomenclatura `R0`–`R7` → `Etapa N — Nome`; tags `etapa1`/`etapa2`.
- `--map <id>`, `MapBuilderRegistry` (builder no JSON) e `GameRoot` genérico.
- Interações base: porta, wallbuy, perk e caixa; smoke `MAP_OK` no CI.
- Blender 4.5.15 LTS + `blender.sh`; fontes `.blend` de 7 modelos e
  `overview.blend`.
- Regra de assets autorais documentada em `18-authored-assets.md`.
- Criados `19-decision-log.md` e `20-work-log.md`; `AGENTS.md`, Kanban, roadmap e
  backlog agora definem o próximo item e o critério de avanço de etapa.
- Organização híbrida adotada: labels/milestone no GitHub, issue #1 para a
  migração do mapa e subagente `doc-keeper` para sincronizar snapshot.

**Testes**
- `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`, `SLICE_OK`, `CI_OK`.

**Commits relevantes**
- `598d021` teste do Bunker 13 falha em regressão
- `1f92711` revisão de base e planejamento
- `3c11536` subagentes de desenvolvimento
- `9e8ba0b` nomenclatura descritiva
- `4101467` `--map` + registry + interações base
- `ee8956a` atualização do progresso
- `d548c78` prefixo `Etapa N`
- `b3efc49` Blender + fontes `.blend` + regra de assets

**Migração de geometria (issue #1) — concluída**
- `SliceBuilder`/`Bunker13Builder` movidos para `src/maps/legacy/` (export-only).
- `tools/export_map.gd` gerou `slice.glb` e `bunker13.glb`; fontes `.blend` em
  `source/blender/maps/` (`slice`, `bunker13`).
- `MapSceneBuilder` carrega o GLB e cria colisão/áreas/labels; JSON só guarda
  âncoras (`builder: "scene"`, `scene: ...`).
- Teste de CI impede `BoxMesh`/`MeshInstance3D` no builder runtime.
- Decisão registrada como D-014 em `19-decision-log.md`.
- KANBAN: migração em **Done**; `WeaponController` 2 slots segue em **Doing**.
- Issue #1 fechada como completed (`etapa:3`, `prio:P0`, `area:assets`,
  milestone Etapa 3); issue #2 aberta (`etapa:3`, `prio:P0`, `area:gameplay`,
  milestone Etapa 3).

**Testes de fechamento (2026-11-06)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `SLICE_OK`, `CI_OK` (inclui `== geometria runtime ==` ok).
- Avisos não fatais: `ObjectDB`/resources em uso no exit dos testes headless.

**Commits da migração**
- `a99f691` `feat: load authored map geometry from GLB`
- `4019c1c` `docs: record authored map geometry migration`

**Mãos compartilhadas + ViewmodelFactory (issue #14) — concluído**
- `source/blender/hands/hands.blend` + `assets/models/hands/hands.glb` com
  `GripSocket`, `HandL`/`HandR` e antebraços (asset único).
- `ViewmodelFactory` monta arma + mãos por `grip_profile`, usando o
  `GripSocket` da arma ou offset de perfil; `viewmodel` do JSON agora controla
  posição/rotação/escala.
- Glock reexportada sem `HandL`/`HandR` embutidos; Glock e MP5 ganharam
  `GripSocket` e `Muzzle` (`prepare_weapon_hands.py`).
- `ContentValidator` exige `hands` compartilhado e `grip_profile` conhecido.
- Teste `VIEWMODEL_OK`: asset único, nenhuma mão embutida, socket aplicado e
  MP5 ponta a ponta (equipar, atirar, recarregar).
- Issue #14 fechada; issue #15 aberta (auditoria de redundância, pedido do
  usuário).
- Commit `d060cdb` `feat: add shared hands and viewmodel factory`.

**Janelas autorais + IA de zumbi em barricadas (issue #13) — concluído**
- Paredes externas do Bunker 13 segmentadas no `.blend`
  (`source/blender/scripts/open_windows.py`), com peitoril/verga e vãos de
  2,2 m; GLB reexportado e colisão por segmento (sem tapar as janelas).
- Spawns de zumbi passaram a usar `barricade.spawn_position`, filtrados por
  salas alcançáveis; fallback para `zombie_spawns` em mapas sem barricadas.
- `ZombieEnemy` com estados `approach → tear → climb → inside`, fila por
  barricada (`try_claim_tearer`) e tempo de arranque escalado pela rodada.
- Teste `ZOMBIE_BARRICADE_OK` cobre aproximação, arranque, fila, breach,
  entrada na sala e path até o player; `BUNKER13_OK` valida os vãos.
- Issue #13 fechada; issue #14 aberta (`hands.glb`/`GripSocket`/`ViewmodelFactory`).
- Commit `5f492d7` `feat: add zombie barricade AI and open bunker windows`.

**Barricadas: estado, hold F e HUD (issue #12) — concluído**
- `BarricadeState` com `plank_count`, `repair_progress` e `breached`; meshes
  `Plank_*` ligados/desligados e área de interação criada pelo builder.
- `BarricadeSystem`: hold F repara 1 tábua por `repair_time`, paga
  `repair_points`, cancela ao soltar F/tomar dano/trocar de arma e expõe
  `tear_plank()` para a IA.
- HUD com painel de progresso de reparo e contador de tábuas.
- Teste `BARRICADE_OK` cobre cheia, arranque, interrupção, dois reparos,
  limite e breach.
- Issue #12 fechada; issue #13 aberta (IA de zumbi em barricadas).
- Commit `6d41ec9` `feat: add barricade repair system`.

**Granada, lança-foguete e barris (issue #11) — concluído**
- Granada (G) com fusível de `ExplosiveData`, contador de 2 cargas e HUD via
  `Events.grenades_changed`; arremesso por `RigidBody3D` autorado.
- `weapon.rocket` (`projectile` + `explosive.frag`) e dano em área.
- `map.barrels` no JSON do Bunker 13 (`barrel_A1/A2`), `BarrelData`,
  `ExplosiveBarrel` com dano por tiro/corpo a corpo e cadeia.
- Assets autorais `barrel.glb`/`grenade.glb` + fontes `.blend`.
- Testes `GRENADE_OK`, `ROCKET_OK` e `BARREL_OK` no CI.
- `ExplosionSystem` e `MapSceneBuilder` passaram a usar duck typing/dicionário
  de explosivos para continuarem válidos em `--script` sem autoloads.
- Issue #11 fechada; issue #12 aberta (`BarricadeSystem`).
- Commit `5aaeffe` `feat: add grenade, rocket launcher and explosive barrels`.

**ExplosionSystem + ExplosiveData (issue #10) — concluído**
- `ExplosionSystem` com shape query, raio, falloff, LOS, `max_targets`,
  impulso em `RigidBody3D` e cadeia por `explosive_chain`/`chain_depth`.
- `ExplosiveData` + `explosive.frag` (JSON/schema/validador).
- `ExplosiveBarrel` encadeável; `Projectile` usa o sistema quando há explosão.
- Camada de física `props` (16) para alvos/impulso.
- Teste `EXPLOSION_OK` (falloff, LOS, impulso e cadeia).
- Issue #10 fechada; issue #11 aberta (granada/foguete/barris).
- Commit `a3dfc0a` `feat: add explosion system and explosive props`.

**Projectile/pellets + MeleeController (issue #9) — concluído**
- `WeaponController` ramifica por `type`: `hitscan` (com `pellets`) e
  `projectile`; `Projectile` move por raycast e aplica dano/explosão básica.
- `Wunder` virou `projectile`.
- `MeleeController` separado, `melee.knife` em JSON, V/cooldown/ray.
- `ContentRegistry` ganhou `melees`; validador e schema de melee.
- Testes `MELEE_OK` e `PROJECTILE_OK` no CI.
- Issue #9 fechada; issue #10 aberta (`ExplosionSystem`).
- Commit `3991bd2` `feat: add melee and projectile weapon support`.

**Economy + RoundManager (issue #8) — concluído**
- `Economy` (`src/gameplay/economy.gd`): pontos, `add`, `can_afford`, `spend`,
  `set_points`; HUD continua via `Events.points_changed`.
- `RoundManager` (`src/gameplay/round_manager.gd`): ondas em salas alcançáveis,
  `spawned`/`alive`, timer de 0.6 s, conclusão e `stop()`.
- `GameRoot` só orquestra: compras usam `economy`; mortes chamam
  `round.notify_killed`; spawn via `spawn_requested`.
- Test runner atualizado para `game.economy`/`game.round`.
- Issue #8 fechada; issue #9 aberta (`WeaponController` projectile/melee).
- Commit `f86a134` `refactor: extract economy and round manager`.

**HUD autoral em `.tscn` (issue #7) — concluído**
- `scenes/ui/hud.tscn` gerado a partir do HUD em código e versionado.
- `hud.gd` agora usa `@onready` + bind de sinais; `_build`/`_mk`/`_place`/
  `_overlay` removidos (~250 linhas).
- `GameRoot` instancia a cena via `HUD_SCENE`.
- Start/pause/gameover, mouse filters, banner, ammo/slot e prompt preservados.
- `PAUSE_OK`, `SLICE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SOFTLOCK_OK` e `CI_OK`
  verdes; screenshots de start/pause validados.
- Issue #7 fechada; issue #8 aberta (`RoundManager`/`Economy`).
- Commit `6a1bfd7` `refactor: move HUD to authored scene`.

**Pool/cache de áudio, tracer e animação (issue #6) — concluído**
- Áudio: pools fixos de 12 `AudioStreamPlayer` e 16 `AudioStreamPlayer3D`.
- Tracer: `BoxMesh` unitário e material emissivo estáticos; escala por distância.
- Zumbi: mapa nome→animação e estado atual; `_play` não varre mais a lista por
  frame; `PackedScene` e strip de root motion cacheados por cena.
- Bench (windowed): antes 61 FPS/16,69 ms/83 draw calls/66,8 MB; depois
  60 FPS/16,57 ms/83 draw calls/67,0 MB — sem regressão; ganho é de alocação.
- Issue #6 fechada; issue #7 aberta (HUD `.tscn`).
- Commits `7396942` `perf: pool audio and cache tracer/animation assets` e
  `6fec227` `docs: record pool and cache block`.

**Harness extraído de `GameRoot` (issue #5) — concluído**
- `tests/test_runner.tscn` roda como cena principal e instancia `main.tscn`;
  casos via `--case slice|smoke|softlock|pause|interaction|slots|ui|shot|bench|mouse|pause_shot`.
- `GameRoot` perdeu os `_run_*`, o despacho por flags e ~250 linhas de harness;
  mantém só a API de jogo.
- CI e `bench.sh` usam a cena de teste; gates preservados.
- Issue #5 fechada; issue #6 aberta (pool/cache).
- Commit `f03abc8` `refactor: extract integration harness from GameRoot`
  e `aaef364` `docs: record harness extraction` (bloco completo no topo do log).

**MapContext e Interactable (issue #4) — concluído**
- Ver bloco no topo do log; substituído por registro próprio com CI e hashes.

**Softlock do Bunker 13 (issue #3) — concluído**
- Ondas só em salas alcançáveis; `zombie_count` total respeitado (3/3/2).
- `MapNav` com BFS de salas/portas; zumbi segue waypoints e idles se não há
  caminho, sem atravessar portas fechadas.
- Economia validada: 8 kills geram 980 pontos; `door1` (750) libera o caminho.
- Teste `SOFTLOCK_OK` no CI; issue #3 fechada; issue #4 aberta (`MapContext`).
- Commit `ce62eb5` `fix: prevent Bunker 13 softlock with reachable waves`.

**2 slots (issue #2) — concluído**
- `PlayerController` com dois `WeaponController` independentes; troca por `1`/`2`,
  scroll e `switch_slot`.
- `WeaponController.set_active`/`dispose`/`refill`: munição e recarga preservadas,
  viewmodel antigo liberado, controller inativo sem `_process`.
- HUD mostra `SLOT N/2` e nome/munição da arma ativa (`slot_changed`).
- Wallbuys e caixa usam `add_weapon`: não duplicam arma; com slots cheios,
  substituem o slot ativo.
- Teste `SLOTS_OK` no CI (troca, munição preservada e sem duplicata).
- Issue #2 fechada; issue #3 aberta para o softlock do Bunker 13 (estado à
  época — hoje fechada).
- KANBAN na época: 2 slots apenas em **Done** (removida a duplicata em
  Review/Test); **Doing** vazio; topo de **Ready** com o softlock (issue #3) e
  depois `MapContext` tipado. Hoje o topo é `MapContext`.
- Commits: `e51f172` `feat: add two weapon slots` e `97055ec`
  `docs: record two-slot implementation`.

**CI do bloco (2026-11-06)**
- `./tests/ci.sh` verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
  `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`, `CI_OK`.

**Correções de input/UI (2026-11-06)**
- Mouse look restaurado: controles decorativos do HUD (`crosshair`, `hitmarker`,
  `damage`, `prompt`) agora usam `MOUSE_FILTER_IGNORE`; eles consumiam o mouse
  capturado.
- Pause com ESC: overlay `PAUSADO` com `CONTINUAR`/`REINICIAR`, mouse liberado
  ao pausar e recapturado ao voltar.
- Interação F validada com raycast real na porta + injeção de tecla; abre a
  porta e gasta os pontos.
- Testes novos no CI: `PAUSE_OK` e `INTERACT_OK`.
- Commit `8edc408` `fix: restore mouse look and add pause menu`.
- `--mouse-test` (display) validou rotação da câmera; `--pause-shot` gerou o
  screenshot do menu.

**Próximo item (KANBAN)**
- Auditoria curta de redundância (issue #15, pedido do usuário); depois,
  faca GLB + `knife_slash`.

**Registro confirmado**
- GitHub: #2 fechada; #3 aberta à época (hoje fechada — ver bloco “Softlock do
  Bunker 13 fechado” no topo) com `etapa:3`, `prio:P0`, `area:gameplay` e
  milestone Etapa 3.
- Estratégia de slots registrada como D-015 em `19-decision-log.md`.

## 2026-11-05 — Etapas 1 e 2 (Preparação/Conteúdo)

**Feito**
- v2 criada; v1 arquivada em `zombie-fps-legacy`.
- Pipeline JSON, `ContentRegistry`, validador, DTOs e testes.
- 2 mapas + 5 armas; Bunker 13 JSON + `Bunker13Builder`.
- Vertical slice jogável (sala, porta, zumbi, Glock, HUD).
- Modelos reorganizados em `assets/models/<categoria>/<id>/`.
- CI local, bench, plugin `bunker_tools` e documentação de planejamento.

**Testes**
- `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `SLICE_OK`, `CI_OK`.

**Commits relevantes**
- `e7617b7` conteúdo R1 e Bunker 13
- `71b36e1` revisão R1 e validação de armas
- `59bc4f4` itens da revisão embutidos na etapa seguinte
