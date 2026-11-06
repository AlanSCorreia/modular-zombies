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

| Fase | Nome | Status | Foco atual |
|---|---|---|---|
| R0 | Preparação | **Concluído** | — |
| R1 | Core + conteúdo | **Em andamento** | Reorganizar assets + Bunker 13 JSON |
| R2 | Loop de gameplay | **Parcial** | Slice jogável |
| R3 | Interações/UI/áudio | Backlog | — |
| R4 | Ferramentas de mapa | Backlog | — |
| R5 | Quests/Easter Eggs | Backlog | — |
| R6 | Escala de conteúdo | Backlog | — |
| R7 | Produção | Backlog | — |

> **Status:** P0 concluído. O vertical slice está jogável e testado (`SLICE_OK`);
> o próximo foco é R1 (assets + Bunker 13 completo).

---

# P0 — Bootstrap (concluído)

### Done
- [x] Git + `.gitignore` + commit inicial
- [x] Commit do slice + tag P0
- [x] `Sfx`, `GameRoot`, plugin `bunker_tools`
- [x] Importação validada no Godot
- [x] Conteúdo JSON + loader + validador
- [x] Vertical slice: sala, porta, zumbi, Glock, HUD
- [x] CI local (`tests/ci.sh`) e bench (`tests/bench.sh`)
- [x] Bench: 42–61 FPS, 135 draw calls, 66 MB

---

# R0 — Preparação

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
- [x] Atualizar docs v2 com decisões atuais (R0–R7, rewrite, C#, tools, JSON, explosivos/faca)
- [x] Definir JSON como fonte de conteúdo
- [x] Definir árvore de assets (`assets/`, `source/`, `content/`, `schemas/`)
- [x] Revisar arquitetura e aprovar fases R1–R7
- [x] Definir que a v1 é apenas histórica
- [x] Criar `Sfx` e `GameRoot`
- [x] Plugin `bunker_tools` (dock)
- [x] Validar importação e autoloads no Godot
- [x] Git + `.gitignore`
- [x] CI local
- [x] Vertical slice jogável
- [x] Bench + orçamento de performance
- [x] Launcher “Bunker 13 v2 — Editor”
- [x] Inventário de assets e convenção de IDs

### Blocked
- *(vazio)*

---

# R1 — Core + conteúdo

**Objetivo:** mapa e conteúdo em JSON; sem `if map_id` no núcleo.  
**Aceite:** Bunker 13 carrega por JSON; validador sem erros; zero conteúdo em `.tres`; 0 refs de asset quebradas.

### Backlog
- [ ] `QuestDefinition`/`RewardDefinition`
- [ ] `MechanicDefinition`
- [ ] Templates de mapa vazio/corredor/arena

### Ready
- [ ] `Bunker13Builder` lendo `MapDefinition`
- [ ] Converter Bunker 13 + 5 armas para JSON
- [ ] JSON de faca, granada, foguete, barris, traps e barricadas
- [ ] Pipeline Blender de armas/mãos (todas as armas + mãos separadas)
- [ ] Validação de assets (paths + importação)
- [ ] Template de arma + schema completo
- [ ] Testes de definições e validação

### Doing
- [ ] Reorganizar assets + completar Bunker 13 em JSON

### Review/Test
- [x] `CONTENT_OK` e `LOGIC_OK` no slice
- [ ] Validar Bunker 13 completo

### Done
- [x] DTOs base: `MapData`, `WeaponData`, `EnemyData`
- [x] Loader JSON + `ContentValidator`
- [x] JSON do slice (mapa, Glock, zumbi)
- [x] Testes de conteúdo/lógica

### Blocked
- *(vazio)*

---

# R2 — Loop de gameplay

**Objetivo:** loop completo + combate com explosivos e faca.  
**Aceite:** Bunker 13 jogável; armas usam JSON + `HandsRig`; faca, explosivos e barricadas funcionando.

### Backlog
- [ ] Perk “Gatilho Duplo” com definição
- [ ] Estatísticas de sessão

### Ready
- [ ] `WeaponController` 2 slots
- [ ] `WeaponController` projectile/melee
- [ ] `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia)
- [ ] Granada (G), lança-foguete e barris explosivos
- [ ] `MeleeController` (V, corte diagonal, lunge, cooldown)
- [ ] `Barricade` + `BarricadeSystem` (tábuas, hold F, pontos)
- [ ] IA de zumbi: arrancar tábua, fila e entrada com 0
- [ ] Testes de barricada (reparo, interrupção, breach)
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
- [ ] Rodada 1 → 2 e game over completos

### Done
- [x] `PlayerController` base
- [x] `WeaponController` Glock/hitscan + animações
- [x] `ZombieEnemy` base
- [x] HUD base
- [x] Loop mínimo do slice

### Blocked
- *(vazio)*

---

# R3 — Interações, UI e áudio

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

# R4 — Ferramentas de mapa

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

# R5 — Quests e Easter Eggs

**Objetivo:** autorar segredos sem código no núcleo.  
**Aceite:** música secreta + main quest de 3 passos jogáveis.

### Backlog
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

# R6 — Escala de conteúdo

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

# R7 — Produção

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
