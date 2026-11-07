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
| `etapa3` | Etapa 3 — Gameplay | **Em andamento** | `RoundManager`/`Economy` |
| `etapa4` | Etapa 4 — Interações | Backlog | — |
| `etapa5` | Etapa 5 — Ferramentas de mapa | Backlog | — |
| `etapa6` | Etapa 6 — Quests e Easter Eggs | Backlog | — |
| `etapa7` | Etapa 7 — Escala de conteúdo | Backlog | — |
| `etapa8` | Etapa 8 — Produção | Backlog | — |

> **Status:** Etapas 1 e 2 concluídas. Geometria autoral, 2 slots, softlock,
> `MapContext`/`Interactable`, harness, pool/cache e HUD em `.tscn` concluídos
> (issues #1–#7 fechadas); o foco agora é `RoundManager`/`Economy` (issue #8).

## Próximo item

- **Etapa ativa:** 3 — Gameplay.
- **Agora (Doing):** *(vazio)*.
- **Próximo:** extrair `RoundManager`/`Economy` do `GameRoot` (issue #8).
- **Depois:** `WeaponController` projectile/melee.
- **Próxima etapa:** 4 — Interações, somente após o aceite da Etapa 3.
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
**Aceite:** Bunker 13 jogável com geometria autoral; armas usam JSON + `HandsRig`;
faca, explosivos e barricadas funcionando.

### Backlog
- [ ] Perk “Gatilho Duplo” com definição
- [ ] Estatísticas de sessão

### Ready
- [ ] `RoundManager`/`Economy` fora do `GameRoot` (P1) — [#8](https://github.com/AlanSCorreia/modular-zombies/issues/8)
- [ ] `WeaponController` projectile/melee
- [ ] `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia)
- [ ] Granada (G), lança-foguete e barris explosivos
- [ ] `MeleeController` (V, corte diagonal, lunge, cooldown)
- [ ] `Barricade` + `BarricadeSystem` (tábuas, hold F, pontos)
- [ ] JSON de faca, granada, foguete, barris e traps
- [ ] Mãos separadas (`hands.glb`) + `GripSocket`
- [ ] Bunker 13 jogável com janelas e barricadas
- [ ] Teste visual do Bunker 13
- [ ] Abrir vãos de janela no perímetro do Bunker 13
- [ ] HUD de reparo de barricada
- [ ] Spawns vinculados a `barricade.spawn_position`
- [ ] Corrigir teste de integração (morte, kill, porta, reload)
- [ ] Reforçar `ContentValidator` (schema, IDs, hands, áudio, moving_parts)
- [ ] Substituir `get_child(0)` por referência tipada
- [ ] IA de zumbi: arrancar tábua, fila e entrada com 0
- [ ] Testes de barricada (reparo, interrupção, breach)
- [ ] `BoxBuilder`/helpers comuns
- [ ] Faca GLB + mãos compartilhadas + `knife_slash`
- [ ] `HandsRig` + cache de mãos + `grip_profile`
- [ ] `ViewmodelFactory` (armas GLB + mãos compartilhadas)
- [ ] Validar workflow com uma segunda arma
- [ ] `RoundManager` (estado, spawn, escalonamento)
- [ ] `Economy` (pontos, compra, bônus)
- [ ] `Effects` (sangue, decais, tracers, cápsulas)

### Doing
- *(vazio)*

### Review/Test
- [x] Slice: tiro, recarga, zumbi, morte e porta
- [x] Revisão de linha de base (3 subagentes)
- [x] Smoke do Bunker 13 + compras (`MAP_OK`)
- [x] Bunker 13 e slice carregam GLB autoral
- [x] Mouse look, ESC/pause e F na porta
- [ ] Rodada 1 → 2 e game over completos

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

### Blocked
- [ ] MP5 de ponta a ponta — depende de `hands.glb` + `ViewmodelFactory`

---

# Etapa 4 — Interações

> Inicia após o aceite da Etapa 3 (geometria autoral + Bunker 13 jogável).

**Objetivo:** conteúdo e apresentação completos.  
**Aceite:** portas, wallbuys, caixa, perks, explosivos/faca, HUD, pause e áudio funcionando.

### Backlog
- [ ] Ajustes de mixagem
- [ ] Acessibilidade (tamanho de fonte/contraste)

### Ready
- [ ] `InteractionSystem` tipado
- [ ] Portas, wallbuys, caixa e perks
- [ ] Traps explosivas e props explosivos do JSON do mapa
- [ ] VFX/SFX de explosão/faca/barricada e HUD de granadas
- [ ] HUD de progresso de reparo de barricada
- [ ] HUD/menu/pause/game over
- [ ] Áudio 2D/3D e música
- [ ] Vinheta, hitmarker e prompts
- [ ] Teste de interação e UI

### Doing
- *(vazio)*

### Review/Test
- [ ] Comprar porta/wallbuy/perk/caixa
- [ ] Prompt e feedback de pontos
- [ ] Pause/resume/restart

### Done
- *(vazio)*

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
- [ ] Plugin `bunker_tools` + dock
- [ ] Criar/duplicar mapa
- [ ] Validador no dock
- [ ] Playtest por mapa
- [ ] Launcher do editor
- [ ] Documentação do autor

### Doing
- *(vazio)*

### Review/Test
- [ ] Criar mapa a partir de template
- [ ] Validador aponta erros reais
- [ ] Playtest abre o mapa correto

### Done
- *(vazio)*

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

### Ready
- [ ] `QuestSystem` + `QuestStep`/`Reward`
- [ ] Triggers: interagir, matar, entrar, coletar
- [ ] Recompensas: pontos, música, arma, perk
- [ ] 3 rádios no Bunker 13
- [ ] `Bunker13PowerMechanic` (mecânica única)
- [ ] Validador de grafo/softlock
- [ ] Debug overlay

### Doing
- *(vazio)*

### Review/Test
- [ ] 3 rádios → música + pontos
- [ ] Passo pulado não quebra a quest
- [ ] Validador detecta ciclo/step órfão

### Done
- *(vazio)*

### Blocked
- *(vazio)*

---

# Etapa 7 — Escala de conteúdo

**Objetivo:** provar que o framework escala.  
**Aceite:** 2º mapa + arma nova sem mudar o núcleo.

### Backlog
- [ ] Terceiro mapa
- [ ] Modo co-op

### Ready
- [ ] Segundo mapa com 2 mecânicas
- [ ] Duas armas novas
- [ ] Uma wonder weapon
- [ ] Um inimigo especial
- [ ] Teste “sem mudança no núcleo”

### Doing
- *(vazio)*

### Review/Test
- [ ] Novo mapa jogável
- [ ] Nova arma no wallbuy/caixa
- [ ] Validador e testes verdes

### Done
- *(vazio)*

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

### Ready
- [ ] Save/load versionado
- [ ] Settings (sensibilidade, volume, qualidade)
- [ ] Exportação Linux + smoke test
- [ ] Pool de áudio/efeitos
- [ ] Navmesh pré-bakeada
- [ ] CI (testes + validador)
- [ ] Soak test 30 min

### Doing
- *(vazio)*

### Review/Test
- [ ] Build abre e joga
- [ ] Performance medida
- [ ] Auditoria de licenças/assets
- [ ] Checklist manual de release

### Done
- *(vazio)*

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
