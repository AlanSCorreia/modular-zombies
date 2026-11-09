---
kind: reference
area: execution
status: active
stage: 8
owner: infra
last_reviewed: 2026-11-09
---

# Checklist de release

## Build

- [x] `./tests/ci.sh` verde.
- [x] `./tools/build_linux.sh` gera binário + PCK e roda smoke.
- [x] `BUILD_OK` no CI.
- [x] Smoke do binário exportado exige `CONTENT_LOADED errors=0`.
- [x] Save/load (`SAVE_OK`) e settings (`SETTINGS_OK`).

## Performance

- [x] Headless: **145 FPS, 0,92 ms, 206 MB** (`PERF_OK`).
- [x] Windowed: **60 FPS, 16,58 ms, 100 draw calls, 70,3 MB** (`tests/bench.sh`).
- [x] Orçamento: FPS ≥ 40, frame ≤ 25 ms, memória ≤ 1 GB.
- [x] Softlocks cobertos por `SOFTLOCK_OK`/`ROUNDS_OK`.

## Soak

- [x] `tests/soak.sh 300`: 300 s / 1.178 iterações sem crash.
- [x] `tests/soak.sh 1800`: 1800 s / 7.063 iterações sem crash.

## Conteúdo e controles

- [x] 3 mapas (`slice`, `bunker13`, `depot`).
- [x] 9 armas + faca/granada/foguete/ray gun.
- [x] 2 inimigos (zumbi/brute) e quests.
- [x] Controles WASD/mouse/1-2/R/V/G/F/ESC/F5/F9.
- [x] `NO_CORE_OK` e `CONTENT_OK`.

## Licenças e release

- [x] Auditar texturas e áudio; origem/licença registrada em `CREDITS.md`
      (Poly Haven CC0, OpenGameArt CC0, Kenney CC0, áudio autoral).
- [x] Modelos de terceiros com atribuição (CC BY 3.0) e `assets/third_party/README.md`.
- [x] Rodar soak de 30 min.
- [ ] Revisar acessibilidade/tamanho de fonte.
- [ ] Confirmar `build/linux/bunker13.x86_64` + `.pck` em máquina limpa.
- [ ] Publicar release com checksums e notas.

**Estado:** build e soak aprovados; licenças documentadas. Falta apenas o
pacote de distribuição (checksums, notas e revisão de acessibilidade).
