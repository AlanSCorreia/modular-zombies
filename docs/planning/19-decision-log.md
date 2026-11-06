# Log de decisões

Registro durável de decisões que afetam arquitetura, escopo e pipeline.
Decisões estruturais longas também viram ADR em `07-adr/`.

| ID | Data | Decisão | Motivo / consequência |
|---|---|---|---|
| D-012 | 2026-11-06 | **Os docs definem a execução.** O próximo item é o `Doing` do Kanban; se vazio, o topo de `Ready` da etapa ativa. Não perguntar próximo passo ao usuário. | Evita interrupção e mantém o trabalho reproduzível. |
| D-011 | 2026-11-06 | **Nenhum modelo 3D em runtime.** Todo modelo tem `.blend` fonte em `source/blender/` e GLB em `assets/models/`. Mapas usam geometria autoral + JSON de âncoras. | Permite abrir/editar no Blender e evita geometria escondida em GDScript. |
| D-010 | 2026-11-06 | **Blender 4.5 LTS** é a ferramenta de modelagem. `./blender.sh` abre a visão geral. | Pipeline único para armas, inimigos, props e mapas. |
| D-009 | 2026-11-06 | **Migração da geometria do mapa é pré-requisito da Etapa 3**, não uma nova etapa. A Etapa 4 começa depois do aceite da Etapa 3. | Mantém a sequência estável e impede construir mais gameplay sobre geometria runtime. |
| D-008 | 2026-11-06 | **Nomenclatura por etapas:** `Etapa N — Nome` (`etapa1`…`etapa8`). IDs de tarefa `ETAPA3.1`. | Substitui `R0`–`R7` por nomes descritivos e ordem explícita. |
| D-007 | 2026-11-06 | **Subagentes de desenvolvimento** com escopo fechado: `explorer`, `test-reviewer`, `content-checker`. | Paraleliza exploração/revisão sem dar edição ampla a agentes. |
| D-006 | 2026-11-06 | **Sem LLM no runtime.** IA do jogo é determinística. | Latência, custo e não determinismo não se justificam. |
| D-005 | 2026-11-06 | **Mãos compartilhadas:** um único `hands.glb` para todas as armas, com poses por `grip_profile`. | Evita mãos duplicadas e mantém o viewmodel consistente. |
| D-004 | 2026-11-05 | **Conteúdo em JSON**; `.tres`/`.tscn` só para assets de engine. | Fonte de verdade auditável e validável. |
| D-003 | 2026-11-05 | **GDScript** em vez de C# até profiling comprovar gargalo. | Menor custo e iteração mais rápida; ver `07-adr/0001`. |
| D-002 | 2026-11-05 | **Reescrever a v2**; a v1 é apenas histórico. | Evita herdar dívida do protótipo. |
| D-001 | 2026-11-05 | **Arquitetura data-driven** com `ContentRegistry`, DTOs e validador. | Conteúdo autoral sem `if map_id` no núcleo. |

## Como registrar

- Decisão nova: adicionar linha no topo da tabela com ID `D-0NN`.
- Decisão estrutural: criar ADR curto em `07-adr/` e referenciar aqui.
- Avanço de execução: registrar em `20-work-log.md`, não aqui.
