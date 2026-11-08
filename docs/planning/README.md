---
kind: index
area: execution
status: active
stage: 7
owner: docs
last_reviewed: 2026-11-08
---

# Planejamento — Bunker 13 v2

> **Execução:** [`../../KANBAN.md`](../../KANBAN.md) + issues do GitHub.
> **Decisões duráveis:** [`19-decision-log.md`](19-decision-log.md).
> **Avanços:** [`20-work-log.md`](20-work-log.md).

## Estado atual (2026-11-08)

- v1 é histórico arquivado em `zombie-fps-legacy`; a v2 é reescrita do runtime.
- **Etapas 1–6 concluídas**; **Etapa 7 — Escala de conteúdo em andamento**.
- Entregue: geometria autoral, 2 slots, softlock/BFS, `MapContext`/`Interactable`,
  harness, pool/cache, HUD `.tscn`, `Economy`/`RoundManager`, projétil/melee,
  explosões, granada/foguete/barris, barricadas, janelas + IA de zumbi, mãos
  compartilhadas/`ViewmodelFactory`, faca com `knife_slash`, rodadas 1→2 e
  traps explosivas, VFX/SFX/HUD de granadas e áudio/mixagem.
- **Próximo:** wonder weapon autoral (#35).
- **Depois:** inimigo especial e teste sem núcleo; escala (#16) fica como
  dívida visual.
- Gates atuais: ver [`08-testing-strategy.md`](08-testing-strategy.md).

## Índice

<!-- INDEX:START -->
### Visão e arquitetura

| Documento | Título |
|---|---|
| [`01-product-vision.md`](01-product-vision.md) | Visão de produto — v2 |
| [`02-architecture.md`](02-architecture.md) | Arquitetura — v2 |
| [`07-adr/0001-gdscript-vs-csharp.md`](07-adr/0001-gdscript-vs-csharp.md) | ADR 0001 — GDScript vs C# |

### Execução e processo

| Documento | Título |
|---|---|
| [`05-roadmap.md`](05-roadmap.md) | Roadmap — v2 |
| [`06-backlog.md`](06-backlog.md) | Backlog — v2 |
| [`08-testing-strategy.md`](08-testing-strategy.md) | Estratégia de testes — v2 |
| [`12-development-workflow.md`](12-development-workflow.md) | Workflow de desenvolvimento |
| [`16-development-agents.md`](16-development-agents.md) | Agentes de desenvolvimento |
| [`19-decision-log.md`](19-decision-log.md) | Log de decisões |
| [`20-work-log.md`](20-work-log.md) | Work log — Etapa 4 |
| [`22-redundancy-audit.md`](22-redundancy-audit.md) | Auditoria curta de redundância |

### Conteúdo, assets e sistemas

| Documento | Título |
|---|---|
| [`03-easter-eggs.md`](03-easter-eggs.md) | Easter Eggs e mecânicas por mapa |
| [`04-map-authoring-tools.md`](04-map-authoring-tools.md) | Ferramentas de autoria de mapas |
| [`09-json-content-pipeline.md`](09-json-content-pipeline.md) | Pipeline de conteúdo JSON e assets |
| [`10-combat-systems.md`](10-combat-systems.md) | Sistemas de combate — explosivos e faca |
| [`11-assets.md`](11-assets.md) | Organização de assets |
| [`13-barricades.md`](13-barricades.md) | Barricadas (janelas) |
| [`14-weapon-workflow.md`](14-weapon-workflow.md) | Workflow de criação de armas |
| [`18-authored-assets.md`](18-authored-assets.md) | Assets autorais — regra do projeto |
| [`23-map-author-quickstart.md`](23-map-author-quickstart.md) | Quickstart — autor de mapas |

### Histórico

| Documento | Título |
|---|---|
| [`archive/15-content-review.md`](archive/15-content-review.md) | Revisão da Etapa 2 — Conteúdo: achados e recomendações _(arquivo)_ |
| [`archive/17-baseline-review.md`](archive/17-baseline-review.md) | Revisão de linha de base da Etapa 3 — Gameplay _(arquivo)_ |
| [`archive/20-work-log-2026-11-detalhado.md`](archive/20-work-log-2026-11-detalhado.md) | Work log _(arquivo)_ |
| [`archive/20-work-log-2026-11-etapa3.md`](archive/20-work-log-2026-11-etapa3.md) | Work log — Etapa 3 _(arquivo)_ |
| [`archive/21-code-review.md`](archive/21-code-review.md) | Revisão de código — boas práticas, performance e velocidade _(arquivo)_ |
| [`archive/README.md`](archive/README.md) | Arquivo de planejamento _(arquivo)_ |
<!-- INDEX:END -->

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
- Docs: front matter obrigatório; valide com `python3 tools/check_docs.py`.
  Índice e gates são gerados com `--write`.
- C# só após profiling e ADR de revisão.
