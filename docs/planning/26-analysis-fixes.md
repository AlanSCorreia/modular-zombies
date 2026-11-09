---
kind: reference
area: execution
status: active
stage: 8
owner: docs
last_reviewed: 2026-11-09
---

# Correções da análise negativa

## Corrigido

- **Save/load:** versão 2; rodada reiniciada no load (`RoundManager.restart_at`),
  portas abertas/energia/slot ativo persistidos, clamps de vida/granadas/pontos,
  fallback para a arma inicial, zumbis antigos limpos.
- **Explosões:** jogador incluído na máscara; `PlayerController.take_damage`
  aceita os argumentos usados pelo `ExplosionSystem`; barris/traps na layer
  sólida 32 e nas masks de jogador/zumbi.
- **UI:** `is_start_visible` com guarda; foco em start/pause/game over;
  `ui_cancel` em `_unhandled_input`; game over pausa a árvore; perda de foco
  pausa; `stretch/aspect=expand`.
- **Gameplay:** recarga usa `reload_chambered/reload_empty`; headshot do Brute
  ajustado; BFS só no timer; animação de ataque repetível; modelo nulo na morte
  tratado; round passado ao barricade; `_play` reemite animação.
- **Dados:** `ContentRegistry` rejeita ID duplicado/schema inválido e bloqueia
  boot com conteúdo parcial; DTOs checam arrays; quests têm `map` e validação
  por mapa; Ray Gun sem `explosive` e com `explosion_radius` explícito.
- **Testes:** trap sem fallback; soak mede memória/objetos/iterações; no-core
  exige arquivos escaneados; import do CI é verificado; contagens flexíveis;
  `map_tools` usa `user://` e checa limpeza; save cobre rodada/portas/energia.
- **Docs/assets:** Kino no `CREDITS.md`; `reference.md` para Glock 17, SKS,
  Ray Gun e faca; menção a `barricade_plank.glb` removida; release notes e
  checklist com Kino pós-release; backlog/KANBAN/arquitetura/workflow
  atualizados.

## Riscos residuais

- **Spawn em barricadas:** `_spawn_wave` mantém o design de usar barricadas
  alcançáveis; um fallback interno exigiria novos spawns interiores por mapa.
  O teste de softlock e o `ZOMBIE_BARRICADE_OK` cobrem o fluxo principal.
- **`PERF_OK` headless:** mede CPU/memória; GPU/draw calls continuam no
  `tests/bench.sh` (execução windowed), não no gate headless.
- **Auditoria de gates:** `check_docs.py` agora exige um emissor real para cada
  gate, mas ainda não prova que o comando correspondente foi invocado no
  `ci.sh`; a cobertura é maior, não total.

## Validação

`./tests/ci.sh` verde após as correções, incluindo `SAVE_OK`, `EXPLOSION_OK`,
`BARRICADE_OK`, `KINO_OK`, `MENU_OK`, `SOAK_OK` e `BUILD_OK`.
