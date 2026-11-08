---
kind: log
area: execution
status: active
stage: 4
owner: docs
last_reviewed: 2026-11-08
---

# Work log — Etapa 4

Registro curto da etapa ativa, **mais recente primeiro**. A Etapa 3 detalhada
está em
[`archive/20-work-log-2026-11-etapa3.md`](archive/20-work-log-2026-11-etapa3.md);
o início do projeto, em
[`archive/20-work-log-2026-11-detalhado.md`](archive/20-work-log-2026-11-detalhado.md).

## 2026-11-08 — Áudio 2D/3D, música e mixagem (issue #24)

- Buses `Music`/`Weapons`/`Zombies`/`UI`/`Foley` criados no `Sfx`; roteamento
  por categoria em `play`/`play_3d`.
- Master volume no pause com slider e persistência em `user://audio.cfg`.
- Stingers de início/fim de rodada na bus Music.
- Teste `AUDIO_OK` cobre buses, chaves e volume; Etapa 4 aceita.
- Próxima etapa: ferramentas de mapa (#25).

## 2026-11-08 — VFX/SFX + HUD de granadas (issue #23)

- Explosão com partículas/luz em `ExplosionSystem` (mesh/material cacheados) e
  som de explosão via pool do `Sfx`.
- SFX para faca, quebra/reparo de barricada e arremesso de granada.
- HUD ganhou contador `GRANADAS N`, ligado a `grenades_changed`.
- Teste `FX_OK` cobre contador, FX de explosão e chaves de áudio.
- Issue #23 fechada; próximo é áudio/mixagem (#24).

## 2026-11-08 — Traps explosivas (issue #22)

- `TrapData`, `map.traps`, schema/validador e `MapContext.traps`.
- `ExplosiveTrap` com área 2|4, corpo 16, `hit()`/`detonate()` e cadeia.
- Asset autoral `trap.blend`/GLB; 2 traps no Bunker 13.
- Teste `TRAP_OK`; Etapa 4 iniciada.

**Próximo item:** criar/duplicar mapa no `bunker_tools` (issue #25); depois
playtest por mapa e documentação do autor.
