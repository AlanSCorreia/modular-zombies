# Workflow de desenvolvimento

## Git

- Repositório da v2 em `zombie-fps-v2`; a v1 é apenas histórico.
- `.gitignore`: `.godot/`, `build/`, logs.
- Commits pequenos e temáticos (`feat:`, `fix:`, `docs:`, `test:`).
- Commitar assets junto do JSON que os referencia.
- Tag de marco ao fechar fase (`R0`, `R1`, ...).
- Nunca commitar `.godot/` nem builds.

## CI local

```bash
./tests/ci.sh     # import + lógica + conteúdo + integração
./tests/bench.sh  # FPS/frame/draw calls/memória
```

O CI deve bloquear qualquer mudança com conteúdo inválido ou teste vermelho.

## Regra do vertical slice

Nenhuma fase avança só com “framework”. Cada entrega precisa ser jogável ou
testável:

- Slice atual: uma sala, porta comprável, zumbi, Glock e HUD.
- Próximo: conteúdo completo do Bunker 13 e mecânicas únicas.
- Ferramentas de mapa só depois de R1–R3 estáveis.

## Orçamento de performance

| Métrica | Limite |
|---|---|
| FPS mínimo (iGPU) | 40 |
| FPS alvo | 60 |
| Frame time | ≤ 25 ms |
| Draw calls | ≤ 500 |
| Memória | ≤ 1 GB |

Medição atual do slice: **60 FPS, 16,5 ms, 135 draw calls, 66 MB** (vsync).
Registrar o bench a cada mudança grande.

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

- Toda decisão estrutural vira ADR curto em `docs/planning/07-adr/`.
- Dúvida de escopo: registrar no Kanban como `Blocked` com motivo.

## Assets

- Fonte `.blend` em `source/blender/` (`.gdignore`).
- Exportar GLB para `assets/` via script; validar escala/pivôs.
- Nenhum asset de terceiros sem licença em `CREDITS.md`.

## Próximos passos (P0 concluído)

1. Reorganizar assets para a árvore híbrida (R1).
2. Completar loader/validador para todas as definições (R1).
3. Portar o Bunker 13 completo por JSON (R1).
4. Fechar o loop de gameplay (R2) e depois UI/áudio (R3).
