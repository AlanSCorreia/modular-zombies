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

## 2026-11-08 — Save/load versionado (issue #37)

- `SaveGame` versionado em `user://savegame.json`.
- Salva pontos, vida, granadas, armas/munição, perks, barricadas, energia,
  rodada e estado das quests.
- `QuestSystem.snapshot()/restore()`; `F5` salva, `F9` carrega.
- Teste `SAVE_OK` cobre round-trip, armas/munição e versão incompatível.
- Próximo: settings (#38).

**Próximo item:** settings — sensibilidade, volume e qualidade (issue #38);
depois exportação e performance.
