---
kind: reference
area: execution
status: active
stage: 8
owner: infra
last_reviewed: 2026-11-08
---

# Checklist de release

## Build

- [x] `./tests/ci.sh` verde.
- [x] `./tools/build_linux.sh` gera binário + PCK e roda smoke.
- [x] `BUILD_OK` no CI.
- [x] Save/load (`SAVE_OK`) e settings (`SETTINGS_OK`).

## Performance

- [x] Headless: **145 FPS, 0,92 ms, 206 MB** (`PERF_OK`).
- [x] Windowed: **60 FPS, 16,58 ms, 100 draw calls, 70,3 MB** (`tests/bench.sh`).
- [x] Orçamento: FPS ≥ 40, frame ≤ 25 ms, memória ≤ 1 GB.
- [x] Softlocks cobertos por `SOFTLOCK_OK`/`ROUNDS_OK`.

## Soak

- [x] `tests/soak.sh 300`: 300 s / 1.178 iterações sem crash.
- [ ] `tests/soak.sh 1800`: 30 min finais antes de distribuir.

## Conteúdo e controles

- [x] 3 mapas (`slice`, `bunker13`, `depot`).
- [x] 9 armas + faca/granada/foguete/ray gun.
- [x] 2 inimigos (zumbi/brute) e quests.
- [x] Controles WASD/mouse/1-2/R/V/G/F/ESC/F5/F9.
- [x] `NO_CORE_OK` e `CONTENT_OK`.

## Licenças e release

- [ ] Auditar/substituir texturas e áudio com licença registrada (`CREDITS.md`).
- [ ] Rodar soak de 30 min.
- [ ] Revisar acessibilidade/tamanho de fonte.
- [ ] Confirmar `build/linux/bunker13.x86_64` + `.pck` em máquina limpa.
- [ ] Publicar release com checksums e notas.

**Estado:** tecnicamente jogável e buildável; **não distribuir publicamente**
antes dos itens de licença/soak.
