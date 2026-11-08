---
kind: log
area: execution
status: active
stage: 8
owner: docs
last_reviewed: 2026-11-08
---

# Work log — Etapa 8

Registro curto da etapa ativa, **mais recente primeiro**. Etapas 4–7 estão em
[`archive/20-work-log-2026-11-etapas4-7.md`](archive/20-work-log-2026-11-etapas4-7.md);
Etapa 3 em
[`archive/20-work-log-2026-11-etapa3.md`](archive/20-work-log-2026-11-etapa3.md).

## 2026-11-08 — Performance, soak e checklist (issue #40)

- `PERF_OK`: headless 145 FPS, 0,92 ms, 206 MB; bench windowed 60 FPS,
  16,58 ms, 100 draw calls, 70,3 MB.
- `tests/soak.sh`: 300 s / 1.178 iterações sem crash.
- `24-release-checklist.md` e `CREDITS.md`; licença e soak de 30 min ficam
  como bloqueio no #41.
- `PERF_OK` entrou no CI junto de `BUILD_OK`.
- Próximo: auditoria de licenças + soak 30 min (#41).

## 2026-11-08 — Exportação Linux + smoke (issue #39)

- `export_presets.cfg` Linux com binário + PCK em `build/linux/`.
- `tools/build_linux.sh` exporta e roda smoke headless.
- `BUILD_OK` no CI valida binário, PCK e inicialização.
- Templates 4.7.2 instalados no ambiente para o export.
- Próximo: performance/soak (#40).

## 2026-11-08 — Settings (issue #38)

- `GameSettings` persistido em `user://settings.cfg`: sensibilidade, volume
  master/música e qualidade (baixa/média/alta).
- Player usa sensibilidade; Sfx aplica volumes; viewport aplica FSR/escala.
- Pause ganhou sliders de música/sensibilidade e seletor de qualidade.
- Teste `SETTINGS_OK` cobre round-trip, clamps, áudio e qualidade.
- Próximo: exportação Linux (#39).

## 2026-11-08 — Save/load versionado (issue #37)

- `SaveGame` versionado em `user://savegame.json`.
- Salva pontos, vida, granadas, armas/munição, perks, barricadas, energia,
  rodada e estado das quests.
- `QuestSystem.snapshot()/restore()`; `F5` salva, `F9` carrega.
- Teste `SAVE_OK` cobre round-trip, armas/munição e versão incompatível.
- Próximo: settings (#38).

**Próximo item:** auditoria de licenças + soak 30 min final (issue #41); depois
aceite final.
