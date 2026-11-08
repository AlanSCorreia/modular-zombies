---
kind: log
area: execution
status: active
stage: 3
owner: docs
last_reviewed: 2026-11-08
---

# Work log — Etapa 3

Registro curto da etapa ativa, **mais recente primeiro**. Detalhes históricos
(issues #1–#15, Etapas 1–2) ficam em
[`archive/20-work-log-2026-11-detalhado.md`](archive/20-work-log-2026-11-detalhado.md).
Decisões duráveis: [`19-decision-log.md`](19-decision-log.md).

## 2026-11-08 — Pipeline de métricas (issue #20)

- `tools/export_history.py`: export somente leitura do SQLite do OpenCode,
  filtrando o projeto; sessões, mensagens, tool calls, tokens, commits, issues
  e logs de CI.
- `metrics/raw/` é privado e ignorado; `tools/metrics.py` gera
  `summary.json`, `per_session.csv`, `per_day.csv` e `per_issue.csv`.
- `tools/metrics_snapshot.sh` roda export + agregação; `AGENTS.md` e
  `doc-keeper` exigem o snapshot no fim de cada bloco.
- Baseline atual: 12 sessões, 1.847 mensagens, 2.257 tool calls, 61 commits,
  19 issues; tokens e gates registrados.
- Issue #20 fechada.

## 2026-11-08 — Automação/validação de docs (issue #19)

- Front matter obrigatório (`kind/area/status/stage/owner/last_reviewed`) em
  `docs/planning/**`.
- `tools/check_docs.py`: links, índice gerado, gates do `ci.sh`, KANBAN
  (1 Doing/Próximo), work log, decisões, IDs do backlog, frases obsoletas e
  idade de revisão.
- `--write` regenera índice e bloco de gates; `--with-github` valida issues via
  `gh`; `--write-cache` mantém `github-issues.json` para uso offline.
- `DOCS_OK` entrou no `tests/ci.sh`; o template `tools/github-docs.yml` permite
  rodar o checker com GitHub quando o token tiver escopo `workflow` (o push
  automático foi bloqueado sem esse escopo).
- KANBAN reduzido para 2 itens de Ready, ambos com issue; CI completo verde.

## 2026-11-08 — Organização das docs (issue #18)

- `README.md` do planejamento virou índice por categoria + estado atual.
- Revisões históricas movidas para `archive/` (`15`, `17`, `21`).
- `20-work-log.md` reescrito curto, mais recente primeiro, sem duplicatas;
  log detalhado preservado em `archive/20-work-log-2026-11-detalhado.md`.
- `12-development-workflow.md`, `08-testing-strategy.md` e `11-assets.md`
  atualizados (hands, comandos `--case`, próximos passos e escala).
- Issue #18 fechada; sem mudança de gameplay.

## 2026-11-07 — Auditoria de redundância (issue #15)

- `22-redundancy-audit.md`: 31 docs; 62% dos commits só de docs; CI com 19
  processos/38,3 s (≈55% em boot); 1 bloco duplicado de runtime.
- Recomendações: status em issue + KANBAN, suíte agrupada local, Ready ≤ 5,
  arquivar builders legados quando possível e rotacionar work log.
- Decisão D-028 registrada; sem mudança de gameplay.

## 2026-11-07 — Mãos compartilhadas + ViewmodelFactory (issue #14)

- `hands.glb` único com `GripSocket`/`HandL`/`HandR` + scripts Blender.
- `ViewmodelFactory` monta arma + mãos por `grip_profile`; JSON controla
  `position`/`rotation`/`scale`.
- Glock reexportada sem mãos embutidas; Glock e MP5 com `GripSocket`/`Muzzle`.
- `VIEWMODEL_OK` cobre asset único e MP5 ponta a ponta; CI verde.

## 2026-11-07 — Janelas autorais + IA de zumbi (issue #13)

- Paredes do Bunker 13 segmentadas com vãos reais (`open_windows.py`).
- Spawns por `barricade.spawn_position`; zumbi com `approach → tear → climb →
  inside` e fila por barricada.
- `ZOMBIE_BARRICADE_OK` cobre aproximação, fila, breach e entrada; CI verde.

## 2026-11-06 — Barricadas: hold F e pontos (issue #12)

- `BarricadeState` por tábua + `BarricadeSystem` (hold F, pontos, cancelamento,
  `tear_plank` para IA).
- HUD de progresso; teste `BARRICADE_OK` (reparo, interrupção, limite, breach).

## 2026-11-06 — Granada, foguete e barris (issue #11)

- Granada (G) com fusível, `weapon.rocket`, barris autorais no Bunker 13 e
  dano por tiro/cadeia.
- `GRENADE_OK`, `ROCKET_OK` e `BARREL_OK` no CI.

## 2026-11-06 — ExplosionSystem (issue #10)

- Raio, falloff, LOS, impulso e cadeia por `explosive_chain`.
- `ExplosiveData`/`explosive.frag`, camada `props`; `EXPLOSION_OK`.

## 2026-11-06 — Projectile/pellets + melee (issue #9)

- `WeaponController` por `type` (`hitscan`/`projectile`) e `MeleeController`
  separado; `MELEE_OK` e `PROJECTILE_OK`.

## 2026-11-06 — Economy + RoundManager (issue #8)

- Loop de ondas/economia extraído do `GameRoot`; spawn em salas alcançáveis.

## 2026-11-06 — HUD autoral em `.tscn` (issue #7)

- Árvore do HUD versionada; `hud.gd` só faz bind de sinais.

## 2026-11-06 — Pool/cache de áudio/tracer/animação (issue #6)

- Pools fixos de áudio, tracer estático e animação por mapa de estados.

## 2026-11-06 — Harness em `tests/` (issue #5)

- `test_runner.tscn` como cena principal; casos via `--case`.

## 2026-11-06 — `MapContext` + `Interactable` (issue #4)

- Estado tipado de portas/compras; `Kind` em enum; fim de strings mágicas.

## 2026-11-06 — Softlock do Bunker 13 (issue #3)

- Ondas só em salas alcançáveis + `MapNav` BFS; `SOFTLOCK_OK`.

## 2026-11-06 — Dois slots (issue #2)

- Dois `WeaponController` independentes; troca, munição e HUD preservados.

## 2026-11-06 — Geometria autoral do mapa (issue #1)

- Mapas em GLB/`.blend`; runtime só cria colisão/áreas/labels.

## 2026-11-06 — Fundação da Etapa 3

- Revisão de base, naming `Etapa N`, `--map`, interações base, Blender LTS e
  regra de assets autorais; issues/milestones no GitHub + `doc-keeper`.

**Próximo item:** faca GLB + `knife_slash` (issue #17); depois normalização de
escala das armas (issue #16).
