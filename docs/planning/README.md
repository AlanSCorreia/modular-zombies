# Planejamento — Bunker 13 v2

> **Execução:** [`../../KANBAN.md`](../../KANBAN.md) + issues do GitHub.
> **Decisões duráveis:** [`19-decision-log.md`](19-decision-log.md).
> **Avanços:** [`20-work-log.md`](20-work-log.md).

## Estado atual (2026-11-08)

- v1 é histórico arquivado em `zombie-fps-legacy`; a v2 é reescrita do runtime.
- **Etapas 1–2 concluídas**; **Etapa 3 — Gameplay em andamento**.
- Entregue: geometria autoral, 2 slots, softlock/BFS, `MapContext`/`Interactable`,
  harness, pool/cache, HUD `.tscn`, `Economy`/`RoundManager`, projétil/melee,
  explosões, granada/foguete/barris, barricadas, janelas + IA de zumbi e mãos
  compartilhadas/`ViewmodelFactory`.
- **Próximo:** faca GLB + `knife_slash` (#17); depois normalizar escala das
  armas (#16).
- Gates atuais: ver [`08-testing-strategy.md`](08-testing-strategy.md).

## Índice

### Visão e arquitetura

| Documento | Conteúdo |
|---|---|
| [`01-product-vision.md`](01-product-vision.md) | Objetivo, pilares e métricas |
| [`02-architecture.md`](02-architecture.md) | v1 vs v2, contratos, DTOs e riscos |
| [`07-adr/0001-gdscript-vs-csharp.md`](07-adr/0001-gdscript-vs-csharp.md) | Decisão de linguagem |

### Execução e processo

| Documento | Conteúdo |
|---|---|
| [`05-roadmap.md`](05-roadmap.md) | Etapas 1–8, entregáveis e aceite |
| [`06-backlog.md`](06-backlog.md) | Épicos e tarefas por fase |
| [`08-testing-strategy.md`](08-testing-strategy.md) | Pirâmide, gates, golden path e CI |
| [`12-development-workflow.md`](12-development-workflow.md) | Git, CI, DoD e performance |
| [`16-development-agents.md`](16-development-agents.md) | Subagentes e escopos |
| [`19-decision-log.md`](19-decision-log.md) | Decisões duráveis (D-001…) |
| [`20-work-log.md`](20-work-log.md) | Log curto da etapa ativa |
| [`22-redundancy-audit.md`](22-redundancy-audit.md) | Auditoria de redundância (issue #15) |

### Conteúdo, assets e sistemas

| Documento | Conteúdo |
|---|---|
| [`09-json-content-pipeline.md`](09-json-content-pipeline.md) | JSON canônico, schemas e validador |
| [`10-combat-systems.md`](10-combat-systems.md) | Explosivos, barris, granada, foguete e faca |
| [`11-assets.md`](11-assets.md) | Árvore de assets, convenções e licenças |
| [`13-barricades.md`](13-barricades.md) | Hold F, tábuas, IA e pontos |
| [`14-weapon-workflow.md`](14-weapon-workflow.md) | Pipeline de armas + mãos compartilhadas |
| [`18-authored-assets.md`](18-authored-assets.md) | Blender → GLB, escala e nomes |
| [`04-map-authoring-tools.md`](04-map-authoring-tools.md) | Ferramentas de mapa (Etapa 5) |
| [`03-easter-eggs.md`](03-easter-eggs.md) | Quests e mecânicas únicas |

### Histórico

| Documento | Conteúdo |
|---|---|
| [`archive/`](archive/README.md) | Revisões e log detalhado de nov/2026 |

## Como usar

1. Leia o **KANBAN** e a issue ativa.
2. Use `05-roadmap.md` para escopo da fase e `06-backlog.md` para tarefas.
3. Decisões novas → `19-decision-log.md`; avanços → `20-work-log.md`.
4. Não duplique status: roadmap/backlog descrevem escopo, não “feito”.
5. Ao fechar a fase: aceite + testes + docs + Kanban + issue.

## Regras

- Uma fase ativa por vez; no máximo 1 item em Doing.
- Conteúdo é JSON validado; zero `.tres` de conteúdo.
- Assets de runtime em `assets/`; fontes `.blend`/scripts em `source/blender/`.
- Nenhum modelo 3D gerado em runtime.
- Toda arma usa o mesmo `hands.glb`.
- C# só após profiling e ADR de revisão.
