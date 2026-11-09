---
kind: log
area: execution
status: active
stage: 8
owner: docs
last_reviewed: 2026-11-09
---

# Work log — Etapa 8

Registro curto da etapa ativa, **mais recente primeiro**. Etapas 4–7 estão em
[`archive/20-work-log-2026-11-etapas4-7.md`](archive/20-work-log-2026-11-etapas4-7.md);
Etapa 3 em
[`archive/20-work-log-2026-11-etapa3.md`](archive/20-work-log-2026-11-etapa3.md).

## 2026-11-09 — Menu principal e pacote de release (issue #43)

- `scenes/ui/main_menu.tscn` virou a cena principal: JOGAR, OPÇÕES e SAIR,
  com áudio ambiente e retorno ao menu pelo pause/game over.
- `GameFlow.auto_start` evita o overlay "INICIAR" duplicado ao entrar pelo menu.
- Opções do menu reutilizam `GameSettings` (volume, música, sensibilidade e
  qualidade).
- Acessibilidade: HUD com fontes mínimas maiores e contraste elevado; menu com
  botões grandes e foco visível.
- `RELEASE_NOTES.md` criado com conteúdo, controles, licenças e checksums.
- Build final com smoke que exige `GAME_STARTED`; artefato validado em `HOME`
  temporário com `CONTENT_LOADED errors=0`.
- `SHA256SUMS` gerado e checksums registrados em `RELEASE_NOTES.md`.
- Próximo: publicar a release no GitHub.

## 2026-11-09 — Fechamento da Etapa 8 (tag `etapa8`)

- CI final verde depois das armas autorais.
- Tag `etapa8` criada e enviada ao remoto.
- Issue #43 aberta para o pacote de distribuição final.

## 2026-11-09 — Armas autorais no lugar dos placeholders (issue #42)

- AK-74, M1911, MP5, M870 e Wunder remodeladas do zero no Blender com
  `weapon_kit.py` + `make_*.py`; fontes `.blend` e `reference.md` em
  `source/blender/weapons/`.
- Escala real em metros, `+Y` frente e `+Z` cima; `GunRoot`, `GripSocket` e
  `Muzzle` presentes em todas; `Magazine`/`Bolt`/`Pump`/`Trigger` nomeados.
- Coronhas, punhos e magazines usam perfis extrudados (`weapon_kit.profile`),
  em vez de caixas empilhadas, para silhuetas curvas e contínuas.
- Experimento low-poly na M1911: guarda do gatilho em anel, painéis com frisos,
  serrilhas, porta de ejeção, comandos laterais e miras com notch.
- `CREDITS.md` e `assets/third_party/README.md` sem atribuição de armas
  externas; só o zumbi continua CC BY 3.0.
- `overview.blend` regenerado; JSONs atualizaram `moving_parts`.
- `VIEWMODEL_OK`, `WEAPONS_OK`, `WONDER_OK` e `KNIFE_OK` verdes.
- Encerra a dívida de escala/origem das armas (#16).
- Próximo: CI final e tag `etapa8`.

## 2026-11-09 — Licenças e soak de 30 min (issue #41)

- Auditoria confirmou a origem das texturas e do áudio no CREDITS do legado:
  Poly Haven CC0, OpenGameArt CC0, Kenney CC0 e trilha/UI sintetizadas.
- `CREDITS.md` reescrito com atribuições (CC BY 3.0 dos modelos de terceiros)
  e `assets/third_party/README.md` registra os packs externos.
- Validador de conteúdo passou a usar `ResourceLoader.exists`; o build
  exportado agora exige `CONTENT_LOADED errors=0` no smoke.
- `tests/soak.sh 1800`: 1800 s / 7.063 iterações sem crash (`SOAK_OK`).
- Build confere em ambiente limpo (HOME temporário) sem erros de conteúdo.
- Próximo: substituir os modelos placeholder por armas autorais.

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

**Próximo item:** pacote de distribuição final (issue #43).
