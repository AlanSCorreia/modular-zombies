---
kind: reference
area: execution
status: active
stage: 8
owner: infra
last_reviewed: 2026-11-09
---

# Agentes de desenvolvimento

## Decisão

Adotamos **skills Godot da comunidade** e reduzimos os agentes próprios ao
mínimo. O agente principal continua responsável por decisões e edições; os
subagentes têm escopo fechado.

Pacote: **GodotPrompter v1.16.1** (MIT), instalado como plugin em
`.opencode/opencode.json`. Ele registra 59 skills Godot 4.x, incluindo
`godot-code-review`, `godot-testing`, `godot-debugging`, `godot-optimization`,
`gdscript-patterns`, `scene-organization` e `state-machine`.

## Agentes

| ID | Papel | Pode editar | Pode executar |
|---|---|---|---|
| `godot-code-reviewer` | Revisa código/regressões Godot usando `godot-code-review` | não | git, `./tests/ci.sh`, `./run.sh --headless`, `check_docs.py` |
| `content-checker` | Valida JSON, referências e mapas do Bunker 13 | não | `./tests/ci.sh`, `./run.sh --headless` |
| `doc-keeper` | Mantém KANBAN, logs e issues do GitHub | `KANBAN.md`, `docs/planning/**` | git, CI, `gh issue` |

Arquivos: `.opencode/agents/<id>.md`.
- `godot-code-reviewer` é o agente `godot-code-reviewer` do GodotPrompter
  adaptado ao frontmatter do OpenCode; o corpo vem do pack (MIT).
- `explorer` e `test-reviewer` foram removidos. Para exploração, use o agente
  embutido `explore`; para testes, o agente principal escreve em `tests/**`.
- O modelo não é fixado; cada subagente herda o modelo da sessão pai.
- As instruções globais do projeto ficam em `AGENTS.md` e prevalecem sobre o
  pack.

## Quando usar

- **Exploração paralela:** “Use o `explore` para mapear como as barricadas se
  conectam ao HUD e ao zumbi.”
- **Revisão antes do commit:** “Use o `godot-code-reviewer` para revisar o diff
  e rodar o CI.”
- **Conteúdo novo/alterado:** “Use o `content-checker` para validar
  `content/maps/bunker13.json` e os assets referenciados.”
- **Fim de bloco/etapa:** “Use o `doc-keeper` para sincronizar KANBAN, work log
  e issues do GitHub.”

## Limites

- Nenhum subagente decide arquitetura ou refatora `src/` sozinho.
- Não usar agente LLM em runtime; a IA do jogo é determinística.
- `godot-code-reviewer` e `content-checker` são somente leitura; achados viram
  tarefa.
- Revisar o resultado: o subagente começa com contexto novo e pode errar.
- Se um agente precisar de mais permissões, altere o `.md` e registre o motivo.

## Fonte e licença

- https://github.com/jame581/GodotPrompter (MIT, v1.16.1).
- O plugin é fixado por tag; o entrypoint registra skills e não altera o jogo.
