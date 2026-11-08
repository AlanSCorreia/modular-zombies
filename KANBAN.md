# Kanban — Bunker 13 v2

**Função:** controlar escopo e progresso da reescrita v2.  
**Regra:** uma fase ativa por vez; no máximo **1 item em Doing**.  
**Fonte de planejamento:** `docs/planning/` (roadmap, arquitetura, backlog).

---

## Legenda

| Coluna | Significado |
|---|---|
| **Backlog** | Ideia aceita, ainda sem detalhe suficiente |
| **Ready** | Critério de aceite claro; pode começar |
| **Doing** | Em execução (máx. 1) |
| **Review/Test** | Implementado; aguardando teste/revisão |
| **Done** | Aceite cumprido e testado |
| **Blocked** | Impedido; motivo obrigatório |

**Prioridade:** P0 bloqueia a fase; P1 próxima; P2 depois.  
**Definição de Done:** aceite atendido + teste verde + doc atualizada + sem regressão.

---

## Visão geral

| ID | Etapa | Status | Foco atual |
|---|---|---|---|
| `etapa1` | Etapa 1 — Preparação | **Concluído** | — |
| `etapa2` | Etapa 2 — Conteúdo | **Concluído** | — |
| `etapa3` | Etapa 3 — Gameplay | **Concluído** | — |
| `etapa4` | Etapa 4 — Interações | **Concluído** | — |
| `etapa5` | Etapa 5 — Ferramentas de mapa | **Concluído** | — |
| `etapa6` | Etapa 6 — Quests e Easter Eggs | **Concluído** | — |
| `etapa7` | Etapa 7 — Escala de conteúdo | **Concluído** | — |
| `etapa8` | Etapa 8 — Produção | **Em andamento** | Settings |

> **Status:** Etapas 3–7 **concluídas** (issues #1–#15 e #17–#36).
> Gameplay, apresentação, ferramentas, quests e escala de conteúdo prontos.
> Etapa 8 começa por save/load; a escala das armas (#16) fica como dívida visual.

## Próximo item

- **Etapa ativa:** 8 — Produção.
- **Agora (Doing):** *(vazio)*.
- **Próximo:** settings — sensibilidade, volume e qualidade (issue #38).
- **Depois:** exportação Linux, pools/navmesh e performance.
- **Última etapa:** 8 — Produção, após o aceite da Etapa 7.
- **Registro:** `19-decision-log.md` e `20-work-log.md`.

---

# Etapa 1 — Preparação

**Objetivo:** arquivar a v1, criar a v2 e validar a base.  
**Aceite:** projeto v2 abre no Godot; assets presentes; regras de escopo aprovadas.

### Backlog
- *(vazio)*

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- *(vazio)*

### Done
- [x] Arquivar v1 em `zombie-fps-legacy`
- [x] Criar `zombie-fps-v2`
- [x] Copiar assets (modelos, texturas, áudio, fontes)
- [x] Scaffold inicial: `project.godot`, `main.tscn`, `event_bus.gd`, `content_registry.gd`
- [x] Criar este Kanban
- [x] Copiar docs de planejamento para a v2
- [x] Criar `README.md` da v2
- [x] Atualizar docs v2 com decisões atuais (Etapas 1–8, rewrite, C#, tools, JSON, explosivos/faca)
- [x] Definir JSON como fonte de conteúdo
- [x] Definir árvore de assets (`assets/`, `source/`, `content/`, `schemas/`)
- [x] Revisar arquitetura e aprovar Etapas 2–8
- [x] Definir que a v1 é apenas histórica
- [x] Criar `Sfx` e `GameRoot`
- [x] Plugin `bunker_tools` (dock)
- [x] Validar importação e autoloads no Godot
- [x] Git + `.gitignore` + commit inicial
- [x] CI local (`tests/ci.sh`) e bench (`tests/bench.sh`)
- [x] Conteúdo JSON + loader + validador
- [x] Commit do slice + tag `etapa1`
- [x] Vertical slice jogável
- [x] Bench: 42–61 FPS, 135 draw calls, 66 MB
- [x] Launcher “Bunker 13 v2 — Editor”
- [x] Inventário de assets e convenção de IDs

### Blocked
- *(vazio)*

---

# Etapa 2 — Conteúdo

**Objetivo:** mapa e conteúdo em JSON; sem `if map_id` no núcleo.  
**Aceite:** Bunker 13 carrega por JSON; validador sem erros; zero conteúdo em `.tres`; 0 refs de asset quebradas.

### Backlog
- *(vazio)*

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- [x] `CONTENT_OK`, `LOGIC_OK` e `BUNKER13_OK`

### Done
- [x] DTOs base: `MapData`, `WeaponData`, `EnemyData`, `WallBuyData`, `PerkData`, `BoxData`, `BarricadeData`
- [x] Loader JSON + `ContentValidator`
- [x] 2 mapas + 5 armas em JSON
- [x] Bunker 13: 4 salas, 4 portas, 4 wallbuys, 3 perks, caixa, 9 barricadas e 9 spawns
- [x] `Bunker13Builder` + teste `BUNKER13_OK`
- [x] Modelos reorganizados em `assets/models/<categoria>/<id>/`
- [x] Template de arma + schema
- [x] Testes de conteúdo/lógica

### Blocked
- *(vazio)*

---

# Etapa 3 — Gameplay

**Objetivo:** loop completo + combate com explosivos e faca.  
**Aceite:** Bunker 13 jogável com geometria autoral; armas usam JSON +
`ViewmodelFactory` (`hands.glb`); faca, explosivos e barricadas funcionando.

### Backlog
- [ ] Perk “Gatilho Duplo” com definição
- [ ] Estatísticas de sessão
- [ ] Teste visual do Bunker 13
- [ ] Corrigir teste de integração (morte, kill, porta, reload)
- [ ] Reforçar `ContentValidator` (schema, IDs, hands, áudio, moving_parts)
- [ ] Substituir `get_child(0)` por referência tipada
- [ ] `BoxBuilder`/helpers comuns
- [ ] `Effects` (sangue, decais, tracers, cápsulas)
- [ ] Normalizar escala/origem das armas (bottleneck visual, depois) — [#16](https://github.com/AlanSCorreia/modular-zombies/issues/16)

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- [x] Slice: tiro, recarga, zumbi, morte e porta
- [x] Revisão de linha de base (3 subagentes)
- [x] Smoke do Bunker 13 + compras (`MAP_OK`)
- [x] Bunker 13 e slice carregam GLB autoral
- [x] Mouse look, ESC/pause e F na porta
- [x] Barricadas: hold F, interrupção, pontos e breach (`BARRICADE_OK`)
- [x] Zumbi arranca tábuas, respeita fila e entra com 0 (`ZOMBIE_BARRICADE_OK`)
- [x] MP5 ponta a ponta + mãos compartilhadas (`VIEWMODEL_OK`)
- [x] Faca visual + swing (`KNIFE_OK`)
- [x] Rodada 1 → 2 e game over completos (`ROUNDS_OK`)

### Done
- [x] `PlayerController` base
- [x] `WeaponController` Glock/hitscan + animações
- [x] `ZombieEnemy` base
- [x] HUD base
- [x] Loop mínimo do slice
- [x] Harness do Bunker 13 com falha real (contador + `quit(1)`)
- [x] `--map <id>` + `MapBuilderRegistry` (builder no JSON)
- [x] `GameRoot` data-driven (mapa, inimigo e builder)
- [x] Interações base: porta, wallbuy, perk e caixa
- [x] `WeaponController` com áudio/escala do JSON
- [x] Smoke `MAP_OK` do Bunker 13 no CI
- [x] Migração da geometria do mapa para GLB autoral (issue #1)
- [x] Blender 4.5 LTS + `blender.sh`
- [x] Fontes `.blend` das 5 armas + zumbi + pistol + mapas (slice, Bunker 13)
- [x] `source/blender/overview.blend` e scripts de importação
- [x] Correções de input/UI: mouse look, pause com ESC e F na porta
- [x] `WeaponController` 2 slots: troca, munição e HUD (`SLOTS_OK`, issue #2)
- [x] Softlock do Bunker 13 + ondas alcançáveis + BFS salas/portas (issue #3)
- [x] `MapContext` tipado + `Interactable` com enum (issue #4)
- [x] Harness de integração extraído para `tests/test_runner.tscn` (issue #5)
- [x] Pool de áudio + cache de tracer/animação (issue #6)
- [x] HUD autoral em `scenes/ui/hud.tscn` (issue #7)
- [x] `Economy` + `RoundManager` extraídos do `GameRoot` (issue #8)
- [x] `WeaponController` projectile/pellets + `MeleeController` (issue #9)
- [x] `ExplosionSystem` + `ExplosiveData` + barril encadeável (issue #10)
- [x] Granada (G), lança-foguete e barris explosivos autorais (issue #11)
- [x] `BarricadeSystem` + hold F + tábuas + HUD de progresso (issue #12)
- [x] Vãos de janela autorais + spawns por barricada + IA de zumbi (issue #13)
- [x] `hands.glb` compartilhado + `GripSocket` + `ViewmodelFactory` (issue #14)
- [x] Auditoria curta de redundância (`22-redundancy-audit.md`, issue #15)
- [x] Organização das docs: índice, archive e work log (issue #18)
- [x] Automação/validação das docs: checker, front matter e gates (issue #19)
- [x] Pipeline de métricas do projeto: histórico + agregados (issue #20)
- [x] Faca GLB + `knife_slash` + mão compartilhada (issue #17)
- [x] Rodada 1→2, HUD de rodada e game over (issue #21)

### Blocked
- *(vazio)*

---

# Etapa 4 — Interações

> Inicia após o aceite da Etapa 3 (geometria autoral + Bunker 13 jogável).

**Objetivo:** conteúdo e apresentação completos.  
**Aceite:** portas, wallbuys, caixa, perks, explosivos/faca, HUD, pause e áudio funcionando.

### Backlog
- [ ] Acessibilidade (tamanho de fonte/contraste)
- [ ] `InteractionSystem` tipado (refactor)
- [ ] Vinheta e polish de prompts
- [ ] Teste de interação e UI

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- [x] Comprar porta/wallbuy/perk/caixa
- [x] Prompt e feedback de pontos
- [x] Pause/resume/restart

### Done
- [x] Portas, wallbuys, caixa e perks
- [x] Traps explosivas + props explosivos no JSON do mapa (issue #22)
- [x] VFX/SFX de explosão/faca/barricada + HUD de granadas (issue #23)
- [x] HUD de progresso de reparo de barricada
- [x] HUD/menu/pause/game over
- [x] Hitmarker e prompts
- [x] Áudio 2D/3D, música, mixagem e volume (issue #24)

### Blocked
- *(vazio)*

---

# Etapa 5 — Ferramentas de mapa

**Objetivo:** criar, validar e testar mapas no editor.  
**Aceite:** mapa novo criado/duplicado/validado/testado sem tocar no núcleo.

### Backlog
- [ ] Marcadores 3D com gizmos
- [ ] Content browser
- [ ] Templates visuais

### Ready
- [ ] Documentação do autor de mapas (P1) — [#27](https://github.com/AlanSCorreia/modular-zombies/issues/27)

### Doing
- *(vazio)*

### Review/Test
- [x] Criar mapa a partir de template
- [x] Validador aponta erros reais
- [x] Playtest abre o mapa correto

### Done
- [x] Plugin `bunker_tools` + dock
- [x] Validador no dock
- [x] Launcher do editor
- [x] Criar/duplicar mapa + template (issue #25)
- [x] Playtest por mapa via override one-shot (issue #26)
- [x] Documentação do autor / quickstart (issue #27)

### Blocked
- *(vazio)*

---

# Etapa 6 — Quests e Easter Eggs

**Objetivo:** autorar segredos sem código no núcleo.  
**Aceite:** música secreta + main quest de 3 passos jogáveis.

### Backlog
- [ ] `QuestDefinition`/`RewardDefinition`
- [ ] `MechanicDefinition`
- [ ] Grafo visual (GraphEdit)
- [ ] Cifras/rádios/lore
- [ ] Co-op
- [ ] Debug overlay

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- [x] 3 rádios → música + pontos (`RADIO_OK`)
- [x] Passo pulado não quebra a quest (`QUEST_OK`)
- [x] Validador detecta ciclo/step órfão (`QUEST_VALIDATOR_OK`)

### Done
- [x] `QuestSystem` + DTOs, triggers e recompensas (issue #28)
- [x] 3 rádios no Bunker 13 + música secreta (issue #29)
- [x] PowerMechanic: energia, luzes e porta (issue #30)
- [x] QuestValidator: referências/órfãos/ciclos (issue #31)
- [x] Main quest de 3 passos (issue #32)

### Blocked
- *(vazio)*

---

# Etapa 7 — Escala de conteúdo

**Objetivo:** provar que o framework escala.  
**Aceite:** 2º mapa + arma nova sem mudar o núcleo.

### Backlog
- [ ] Terceiro mapa
- [ ] Modo co-op
- [ ] Teste “sem mudança no núcleo”

### Ready
- *(vazio)*

### Doing
- *(vazio)*

### Review/Test
- [x] Novo mapa jogável (`SECOND_MAP_OK`)
- [x] Nova arma no wallbuy/caixa (`WEAPONS_OK`)
- [x] Wonder weapon (`WONDER_OK`)
- [ ] Nova arma no wallbuy/caixa
- [ ] Validador e testes verdes

### Done
- [x] Save/load versionado da run (issue #37)

### Blocked
- *(vazio)*

---

# Etapa 8 — Produção

**Objetivo:** versão distribuível e estável.  
**Aceite:** build standalone, FPS ≥ 40 na iGPU, zero softlocks.

### Backlog
- [ ] Localização
- [ ] Suporte a controle
- [ ] Mods
- [ ] Exportação Linux + smoke test
- [ ] Pool de áudio/efeitos
- [ ] Navmesh pré-bakeada
- [ ] CI (testes + validador)
- [ ] Soak test 30 min

### Ready
- [ ] Settings — sensibilidade, volume e qualidade (P0) — [#38](https://github.com/AlanSCorreia/modular-zombies/issues/38)

### Doing
- *(vazio)*

### Review/Test
- [x] Save/load round-trip (`SAVE_OK`)
- [ ] Build abre e joga
- [ ] Performance medida
- [ ] Auditoria de licenças/assets
- [ ] Checklist manual de release

### Done

### Blocked
- *(vazio)*

---

# Fora de escopo (não adicionar sem revisão)

- Multiplayer em rede.
- Réplica 1:1 de mapas/armas de Call of Duty.
- Assets extraídos de jogos comerciais.
- Editor AAA completo antes de 2 mapas.
- Migração para C# sem profiling de CPU.

---

# Como atualizar

1. Puxe um item de **Ready** para **Doing** (máx. 1).
2. Ao terminar, mova para **Review/Test**.
3. Só mova para **Done** com aceite + teste verde.
4. Se travar, mova para **Blocked** com o motivo.
5. Atualize a **Visão geral** ao fechar uma fase.
6. Não crie itens sem fase e critério de aceite.
