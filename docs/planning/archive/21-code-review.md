---
kind: archive
area: history
status: archive
stage: 3
owner: docs
last_reviewed: 2026-11-08
---

# Revisão de código — boas práticas, performance e velocidade

**Data:** 2026-11-06  
**Método:** revisão dos subagentes `explorer` e `test-reviewer` + CI/bench.
**Escopo:** runtime atual (GameRoot, player/arma, zumbi, HUD, mapas, testes).

## Veredito

- **Dados e processo:** boas práticas acima da média para um protótipo.
- **Runtime:** ainda é código de protótipo; a dívida principal está na composição
  de cena, no `GameRoot` e no `WeaponController`.
- **Performance:** suficiente para 8 zumbis e dois mapas; as ineficiências
  atuais são baratas, mas algumas vão doer ao escalar.
- **Velocidade:** **sim, o estilo atual atrasa** — não pelos docs/CI, mas pela
  arquitetura de runtime. Cada item novo (2 slots, barricadas, IA) exige mexer
  em vários pontos ao mesmo tempo.
- **Atualização:** 2 slots, softlock, `MapContext`/`Interactable`, harness,
  HUD em `.tscn` e `Economy`/`RoundManager` concluídos; factory/mãos continuam
  pendentes.

## Boas práticas presentes

- Conteúdo em JSON + DTOs + validador (`src/content/`), sem conteúdo em `.tres`.
- Event bus desacoplando HUD e gameplay (`src/core/event_bus.gd`).
- Registry de builders, sem `if map_id` no núcleo (`src/maps/map_builder_registry.gd`).
- Geometria autoral em GLB e teste que barra geometria de mapa em runtime.
- Cache de materiais/texturas (`src/core/materials.gd`).
- CI com testes de lógica, conteúdo, mapa, smoke, pausa e interação.
- Documentação de decisões, work log e issues.

## Dívidas que mais atrasam

1. **`GameRoot` monolítico** — reduzido: harness saiu para
   `tests/test_runner.tscn`; `Economy` e `RoundManager` foram extraídos. Ainda
   concentra compras, pausa, HUD e handlers.
2. **`ctx: Dictionary` com strings mágicas** (`game_root.gd:9,179-186`): o
   contrato entre builder e gameplay não é tipado; `kind` aparece no builder,
   no prompt e na compra. `door_open` global duplica o estado de cada porta.
3. **`WeaponController` específico da Glock** (`weapon_controller.gd`):
   hitscan/pellets/projectile e melee separado implementados; `moving_parts`,
   `viewmodel` e `hands` do JSON ainda são ignorados e a animação é montada
   para a Glock. `ViewmodelFactory`/`HandsRig` continuam pendentes — o MP5
   segue bloqueado por isso.
4. **HUD 100% em código** — resolvido: `scenes/ui/hud.tscn` guarda a árvore;
   `hud.gd` só faz bind/sinais.
5. **Sem composição de cena**: `main.tscn` só tem `GameRoot`; player, arma,
   zumbi e colisão ainda são criados por `.new()`. O HUD já é cena.
6. **Fonte de verdade duplicada**: posições de portas/wallbuys/perks/barricadas
   estão no JSON, mas o runtime usa o GLB; os campos do JSON ficaram inertes.
7. **Testes por tempo/contagem**: `--test` dorme ~4 s e usa margem de 150 ms;
   contagens fixas quebram a cada arma/mapa novo; falsos positivos.
8. **Vazamentos**: música/recursos no exit (`4 ObjectDB leaked / 2 resources`);
   troca de arma vaza o controller/rig.

## Performance e algoritmos

**Agora:** o custo é baixo. Bench headless mediu ~145 FPS, 0,29–0,62 ms de
processo e 165–200 MB. Não há necessidade de ECS, pooling geral ou LOD só para
o slice atual.

**Onde está caro / vai escalar mal:**
- Zumbi: `_play` ainda varria animações por frame e reescrevia setup por spawn;
  resolvido com mapa/estado de animação e cache de cena (issue #6).
- Tracer tinha `MeshInstance3D` + `BoxMesh` + material por tiro; agora mesh e
  material são estáticos (node ainda é criado por tiro).
- Áudio criava player por som; agora usa pools fixos 2D/3D.
- HUD ainda emite `prompt_changed` a cada frame, mesmo sem mudança
  (`player_controller.gd:124-144`).
- `MapSceneBuilder` cria um `StaticBody3D`/`BoxShape3D` por mesh (centenas)
  (`map_scene_builder.gd:64-95`); funciona, mas infla broadphase/import.
- Sem navmesh: zumbis empurram direto contra portas fechadas.

**Resolvido:** o softlock do Bunker 13 foi corrigido com ondas em salas
alcançáveis e BFS de salas/portas (`SOFTLOCK_OK`); navmesh fica para mapas
irregulares.

## O que eu faria primeiro

1. **`MapContext` tipado + `Interactable`** — feito: estado de porta em
   `DoorState.open`, enum no lugar de strings e sem `door_open` global.
2. **`WeaponSlots` + `ViewmodelFactory`** — 2 slots resolvidos com controllers
   independentes; faltam `ViewmodelFactory`/`HandsRig` e `moving_parts`/
   `viewmodel`/`hands` do JSON. É o bloqueio do MP5.
3. **Extrair o harness de `GameRoot`** — feito em `tests/test_runner.tscn`;
   restam sleeps/contagens residuais e invariantes mais fortes.
4. **Corrigir o softlock**: feito com ondas em salas alcançáveis e BFS de
   salas/portas (`SOFTLOCK_OK`). Navmesh fica para mapas irregulares.
5. **Cache/pool rápido**: tracer, áudio e animações feitos; ainda faltam
   prompt só na mudança e um `StaticBody3D` por sala/grupo.
6. **HUD em `.tscn`** e `RoundManager`/`Economy` fora do `GameRoot` — feitos;
   faltam InputMap e validação de áudio/partes.

## Processo

Os docs, Kanban, issues e agentes **não são o gargalo**. Eles já evitaram
regressões e mantêm o contexto. O custo real é a arquitetura acima: cada
feature nova exige tocar em `GameRoot`, `PlayerController`, `WeaponController` e
`hud.gd`. Depois dos itens 1–3, a velocidade de entrega deve subir bastante.
