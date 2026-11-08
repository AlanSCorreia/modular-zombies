---
kind: planning
area: execution
status: active
stage: 3
owner: docs
last_reviewed: 2026-11-08
---

# Workflow de desenvolvimento

## Git

- Repositório da v2 em `zombie-fps-v2`; a v1 é apenas histórico.
- `.gitignore`: `.godot/`, `build/`, logs.
- Commits pequenos e temáticos (`feat:`, `fix:`, `docs:`, `test:`).
- Commitar assets junto do JSON que os referencia.
- Tag de marco ao fechar etapa (`etapa1`, `etapa2`, ...).
- Nunca commitar `.godot/` nem builds.

## Agentes de desenvolvimento

Subagentes do OpenCode com escopo fechado ficam em `.opencode/agents/`:
`explorer` (somente leitura), `test-reviewer` (revisão + testes) e
`content-checker` (validação de JSON/assets). Detalhes e limites em
[`16-development-agents.md`](16-development-agents.md).

## CI local

```bash
./tests/ci.sh     # docs + import + lógica + conteúdo + integração
./tests/bench.sh  # FPS/frame/draw calls/memória
```

O CI deve bloquear qualquer mudança com conteúdo inválido ou teste vermelho.

## Docs

- Todo `.md` em `docs/planning/` tem front matter (`kind`, `area`, `status`,
  `stage`, `owner`, `last_reviewed`).
- Validação offline: `python3 tools/check_docs.py`.
- Regenerar índice/gates: `python3 tools/check_docs.py --write`.
- GitHub opcional: `python3 tools/check_docs.py --with-github`.
- Atualizar cache offline: `--with-github --write-cache`.
- O CI roda o checker offline; o workflow de GitHub é o template
  `tools/github-docs.yml` (copie para `.github/workflows/docs.yml` quando o
  token tiver escopo `workflow`).
- Prosa, decisões e work log continuam manuais; o script valida estrutura,
  links e consistência.
- Métricas: `./tools/metrics_snapshot.sh` no fim do bloco. Raw privado em
  `metrics/raw/` (ignorado); agregados em `metrics/aggregates/`. Detalhes em
  `metrics/README.md`.

## Regra do vertical slice

Nenhuma fase avança só com “framework”. Cada entrega precisa ser jogável ou
testável:

- Slice atual: Bunker 13 com geometria autoral, portas, compras, 2 slots, HUD,
  explosivos, barricadas, janelas com IA e mãos compartilhadas.
- Próximo: faca GLB + `knife_slash`; depois normalização de escala das armas.
- Ferramentas de mapa só depois das Etapas 4–6 estáveis.

## Orçamento de performance

| Métrica | Limite |
|---|---|
| FPS mínimo (iGPU) | 40 |
| FPS alvo | 60 |
| Frame time | ≤ 25 ms |
| Draw calls | ≤ 500 |
| Memória | ≤ 1 GB |

Medição atual (2026-11-06, windowed): **~60 FPS, 16,6 ms, 83 draw calls,
67 MB** (varia com vsync/foco da janela). Registrar o bench a cada mudança
grande.

## Definition of Ready

- Objetivo e aceite claros.
- Dependências resolvidas.
- Dados/JSON definidos.
- Como testar descrito.

## Definition of Done

- Aceite cumprido.
- Testes verdes (`ci.sh`).
- Conteúdo validado.
- Bench dentro do orçamento.
- Docs e Kanban atualizados.
- Sem softlock conhecido.

## Decisões

- Decisão estrutural de gameplay/projeto → `19-decision-log.md` (D-001…).
- Decisão de arquitetura/linguagem que mereça contexto longo → ADR curto em
  `07-adr/`.
- Dúvida de escopo: registrar no Kanban como `Blocked` com motivo.

## Assets

- Fonte `.blend` em `source/blender/` (`.gdignore`).
- Exportar GLB para `assets/` via script; validar escala/pivôs.
- Nenhum asset de terceiros sem licença em `CREDITS.md`.

## Próximos passos (Etapa 3 — Gameplay)

1. Faca GLB + `knife_slash` (issue #17).
2. Normalizar escala/origem das armas (issue #16).
3. Fechar rodada 1 → 2, game over e efeitos.
4. UI/áudio de combate (Etapa 4 — Interações).
5. Ferramentas de mapa (Etapa 5 — Ferramentas).
