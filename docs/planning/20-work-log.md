# Work log

Registro cronológico curto do que foi feito, testes e commits. O plano vivo
continua em `05-roadmap.md`, `06-backlog.md` e `KANBAN.md`.

## 2026-11-06 — Etapa 3 (Gameplay) em andamento

**Feito**
- Revisão de base com 3 subagentes; achados em `17-baseline-review.md`.
- Harness do Bunker 13 passou a falhar de verdade (`quit(1)`).
- Nomenclatura `R0`–`R7` → `Etapa N — Nome`; tags `etapa1`/`etapa2`.
- `--map <id>`, `MapBuilderRegistry` (builder no JSON) e `GameRoot` genérico.
- Interações base: porta, wallbuy, perk e caixa; smoke `MAP_OK` no CI.
- Blender 4.5.15 LTS + `blender.sh`; fontes `.blend` de 7 modelos e
  `overview.blend`.
- Regra de assets autorais documentada em `18-authored-assets.md`.
- Criados `19-decision-log.md` e `20-work-log.md`; `AGENTS.md`, Kanban, roadmap e
  backlog agora definem o Norte e o critério de avanço de etapa.

**Testes**
- `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`, `SLICE_OK`, `CI_OK`.

**Commits relevantes**
- `598d021` teste do Bunker 13 falha em regressão
- `1f92711` revisão de base e planejamento
- `3c11536` subagentes de desenvolvimento
- `9e8ba0b` nomenclatura descritiva
- `4101467` `--map` + registry + interações base
- `ee8956a` atualização do progresso
- `d548c78` prefixo `Etapa N`
- `b3efc49` Blender + fontes `.blend` + regra de assets

**Próximo item (KANBAN)**
- Migrar a geometria do mapa para cena autoral (GLB/`.tscn`).

## 2026-11-05 — Etapas 1 e 2 (Preparação/Conteúdo)

**Feito**
- v2 criada; v1 arquivada em `zombie-fps-legacy`.
- Pipeline JSON, `ContentRegistry`, validador, DTOs e testes.
- 2 mapas + 5 armas; Bunker 13 JSON + `Bunker13Builder`.
- Vertical slice jogável (sala, porta, zumbi, Glock, HUD).
- Modelos reorganizados em `assets/models/<categoria>/<id>/`.
- CI local, bench, plugin `bunker_tools` e documentação de planejamento.

**Testes**
- `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `SLICE_OK`, `CI_OK`.

**Commits relevantes**
- `e7617b7` conteúdo R1 e Bunker 13
- `71b36e1` revisão R1 e validação de armas
- `59bc4f4` itens da revisão embutidos na etapa seguinte
