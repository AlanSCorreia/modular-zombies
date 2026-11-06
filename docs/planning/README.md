# Planejamento — Bunker 13 v2

> **Execução:** o board operacional é [`../../KANBAN.md`](../../KANBAN.md)
> (fases Preparação–Produção). Este diretório guarda a estratégia de longo prazo.

## Estado atual

- A v1 é um protótipo histórico arquivado em `../../../zombie-fps-legacy`; não é fonte de verdade.
- A v2 é uma **reescrita do runtime**, não uma refatoração incremental.
- **Preparação concluída:** Git, CI, importação, scaffold, vertical slice jogável.
- Fase atual: **Conteúdo concluído; Gameplay em andamento** (barricadas/faca/explosivos).
- Vertical slice jogável + Bunker 13 em JSON/`Bunker13Builder`; testes `SLICE_OK` e `BUNKER13_OK`.
- Barricadas estão planejadas para a fase de Gameplay (`13-barricades.md`).
- Modelos reorganizados; mãos separadas e fontes `.blend` ficam para a fase de Gameplay.

## Decisões atuais

1. **Reescrever o runtime**; a v1 é apenas histórico, não há dependência.
2. **Conteúdo JSON**: mapas, armas, explosivos, inimigos, perks e quests
   definidos em `.json`, validados e convertidos em DTOs tipados.
3. **Serviços + EventBus**: `RoundManager`, `Economy`, `InteractionSystem`,
   `QuestSystem`, `MapMechanic`, `ExplosionSystem`, `MeleeController`.
4. **Ferramentas de mapa** no editor Godot (fase Ferramentas), editando JSON.
5. **GDScript**: C# não é adotado sem profiling que comprove gargalo de CPU
   (ver ADR).
6. **Kanban controla o escopo**; docs controlam a estratégia.
7. **Assets de engine** usam `.tres`/`.tscn`; binários em `assets/`; fontes
   `.blend` em `source/blender/` com `.gdignore`.

## Índice

| Documento | Conteúdo |
|---|---|
| `01-product-vision.md` | Objetivo, estratégia de rewrite, pilares e métricas |
| `02-architecture.md` | v1 vs v2, contratos, migração e riscos |
| `03-easter-eggs.md` | Pesquisa, mecânicas genéricas e modelo de quests |
| `04-map-authoring-tools.md` | Ferramentas de mapa (Ferramentas/Quests) |
| `05-roadmap.md` | Fases Preparação–Produção, entregáveis e aceite |
| `06-backlog.md` | Épicos e tarefas por fase |
| `07-adr/0001-gdscript-vs-csharp.md` | Decisão de linguagem |
| `08-testing-strategy.md` | Pirâmide, portões, golden path e CI |
| `09-json-content-pipeline.md` | JSON canônico, schemas, loader e validador |
| `10-combat-systems.md` | Explosivos, granadas, foguetes, barris e faca |
| `11-assets.md` | Árvore de assets, convenções, importação e licenças |
| `12-development-workflow.md` | Git, CI, vertical slice e orçamento de performance |
| `13-barricades.md` | Mecânica de barricadas, hold F, zumbis e pontos |
| `14-weapon-workflow.md` | Pipeline completo de criação de armas |
| `15-content-review.md` | Achados e recomendações após Conteúdo |
| `16-development-agents.md` | Subagentes de exploração, revisão e validação |
| `17-baseline-review.md` | Revisão de base antes de Gameplay e ordem recomendada |

## Como usar

1. Veja o **Kanban** para o que está em execução.
2. Use `05-roadmap.md` para o escopo da fase.
3. Puxe tarefas de `06-backlog.md`.
4. Ao fechar a fase: aceite + testes + docs + Kanban atualizados.
5. Não avance de fase sem o portão de teste correspondente.

## Regras de planejamento

- Uma fase ativa por vez; WIP máximo de 1 item.
- Nenhuma ferramenta de autoria antes da base data-driven.
- Nenhuma mecânica de mapa hardcoded no núcleo.
- Todo conteúdo é JSON e passa pelo validador; zero `.tres` de conteúdo.
- Assets de engine (materiais, cenas, animações compostas) em `.tres`/`.tscn`.
- Modelos/texturas/áudio em `assets/`; `.blend` em `source/blender/`.
- Detalhes de organização: `11-assets.md`.
- Explosivos e faca seguem os contratos de `10-combat-systems.md`.
- Toda decisão estrutural vira ADR ou doc.
- C# só após profiling e ADR de revisão.
