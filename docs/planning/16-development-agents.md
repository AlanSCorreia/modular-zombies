# Agentes de desenvolvimento

## Decisão

Adotamos **subagentes de desenvolvimento** no OpenCode, com escopo fechado e
preferência por somente leitura. Eles não rodam no jogo e não substituem a
arquitetura: o agente principal continua responsável por decisões e edições.

## Agentes

| ID | Papel | Pode editar | Pode executar |
|---|---|---|---|
| `explorer` | Mapeia código, cenas, assets e JSON | não | nada (só `read`/`glob`/`grep`) |
| `test-reviewer` | Revisa diff/regressões e escreve testes | `tests/**` | `git diff/status/log/show`, `./tests/ci.sh`, `./run.sh --headless` |
| `content-checker` | Valida JSON, referências e mapas | não | `./tests/ci.sh`, `./run.sh --headless` |

Arquivos: `.opencode/agents/<id>.md`. O modelo não é fixado; cada subagente
herda o modelo da sessão pai. As instruções globais do projeto ficam em
`AGENTS.md`.

## Quando usar

- **Exploração paralela:** “Use o subagente `explorer` para mapear como as
  barricadas se conectam ao HUD e ao zumbi.”
- **Revisão antes do commit:** “Use o `test-reviewer` para revisar o diff e
  rodar o CI.”
- **Conteúdo novo/alterado:** “Use o `content-checker` para validar
  `content/maps/bunker13.json` e os assets referenciados.”

## Limites

- Nenhum subagente decide arquitetura ou refatora `src/` sozinho.
- Não usar agente LLM em runtime; a IA do jogo é determinística.
- `test-reviewer` não altera `src/` nem `content/`; achados viram tarefa.
- Revisar o resultado: o subagente começa com contexto novo e pode errar.
- Se um agente precisar de mais permissões, altere o `.md` e registre o motivo.
