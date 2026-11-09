# Retrospectiva quantitativa — Bunker 13 v2

Gerado em 2026-11-09.

## Escala

- Período: **2026-11-06 → 2026-11-09**
- Commits: **119**
- Autores: AlanSCorreia
- Issues: **49** (48 fechadas, 1 abertas)
- Tags: etapa1, etapa2, etapa3, etapa4, etapa5, etapa6, etapa7, etapa8
- Docs de planejamento: **23**

## Entrega

- Lead time médio (issues fechadas): **0.1 dias**
- Lead time mediano: **0.0 dias**
- Commits de correção (`fix:`): **5** (4.2% do total)
- Decisões registradas: **60**
- Entradas no work log: **15**

### Issues fechadas por milestone

| Milestone | Issues |
|---|---:|
| Etapa 3 — Gameplay | 17 |
| Etapa 8 — Produção | 12 |
| Etapa 6 — Quests e Easter Eggs | 5 |
| Etapa 7 — Escala de conteúdo | 4 |
| Etapa 5 — Ferramentas de mapa | 3 |
| Etapa 4 — Interações | 3 |

### Labels mais usadas

| Label | Issues |
|---|---:|
| `area:gameplay` | 31 |
| `prio:P0` | 28 |
| `prio:P1` | 18 |
| `etapa:3` | 17 |
| `area:infra` | 15 |
| `area:assets` | 15 |
| `etapa:8` | 12 |
| `area:docs` | 12 |
| `etapa:6` | 5 |
| `etapa:7` | 4 |
| `etapa:5` | 3 |
| `etapa:4` | 3 |

## Código

| Categoria | Arquivos | Linhas |
|---|---:|---:|
| GDScript src | 60 | 5603 |
| Cenas/resources | 3 | 1028 |
| Testes | 11 | 1970 |
| Ferramentas | 7 | 1588 |
| Scripts Blender | 22 | 2648 |

### Hotspots de churn

| Arquivo | Linhas alteradas |
|---|---:|
| `tests/test_runner.gd` | 1467 |
| `KANBAN.md` | 1464 |
| `docs/planning/20-work-log.md` | 1390 |
| `src/gameplay/game_root.gd` | 1314 |
| `metrics/aggregates/summary.json` | 1262 |
| `content/maps/kino.json` | 1181 |
| `docs/planning/06-backlog.md` | 943 |
| `docs/planning/05-roadmap.md` | 816 |
| `scenes/ui/hud.tscn` | 784 |
| `src/gameplay/ui/hud.gd` | 724 |
| `docs/planning/github-issues.json` | 589 |
| `source/blender/scripts/make_kino.py` | 526 |
| `docs/planning/README.md` | 525 |
| `tools/check_docs.py` | 513 |
| `src/maps/map_scene_builder.gd` | 471 |

## Conteúdo e assets

- JSON de conteúdo: **21**
  - `enemy`: 2
  - `explosive`: 1
  - `map`: 4
  - `melee`: 1
  - `quest`: 4
  - `weapon`: 9
- GLBs: **21**
- Fontes `.blend`: **22**
- Tamanho de `assets/`: **52.4 MB**

## Testes e CI

- Gates `_OK` esperados: **0**
- Logs de CI no agregado: **0**
- Falhas históricas registradas: **0**

## Processo e IA

- Sessões: **21**
- Mensagens: **3293**
- Tool calls: **3944**
- Tokens de trabalho (input+output+reasoning): **19.3 M**
- Cache read: **1086 M**
- Tokens de trabalho por issue fechada: **403 k**
- Ferramentas mais usadas: shell=1820, edit=916, read=600, write=305, grep=127, glob=74, skill=33, websearch=25

## Observações

- Métricas de token/IA são de sessões locais e não substituem custo real de tempo.
- Lead time usa `createdAt`/`closedAt` do GitHub quando `--github` é usado;
  com cache local, os campos podem estar ausentes.
- Churn e LOC são indicadores de esforço, não de qualidade.
