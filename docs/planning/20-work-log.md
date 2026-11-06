# Work log

Registro cronológico curto do que foi feito, testes e commits. O plano vivo
continua em `05-roadmap.md`, `06-backlog.md` e `KANBAN.md`.

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

**2 slots (issue #2) — concluído**
- `PlayerController` com dois `WeaponController` independentes; troca por `1`/`2`,
  scroll e `switch_slot`.
- `WeaponController.set_active`/`dispose`/`refill`: munição e recarga preservadas,
  viewmodel antigo liberado, controller inativo sem `_process`.
- HUD mostra `SLOT N/2` e nome/munição da arma ativa (`slot_changed`).
- Wallbuys e caixa usam `add_weapon`: não duplicam arma; com slots cheios,
  substituem o slot ativo.
- Teste `SLOTS_OK` no CI (troca, munição preservada e sem duplicata).
- Issue #2 fechada; issue #3 aberta para o softlock do Bunker 13.
- KANBAN: 2 slots apenas em **Done** (removida a duplicata em Review/Test);
  **Doing** vazio; topo de **Ready** segue com o softlock (issue #3) e depois
  `MapContext` tipado.
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
- Corrigir softlock do Bunker 13 + spawns alcançáveis (issue #3); depois,
  `MapContext` tipado + `Interactable`.

**Registro confirmado**
- GitHub: #2 fechada; #3 aberta com `etapa:3`, `prio:P0`, `area:gameplay` e
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
