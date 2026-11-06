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
| R0 | Preparação | **Em revisão** | Docs revisados; validar importação |
| R1 | Core + conteúdo | Backlog | — |
| R2 | Loop de gameplay | Backlog | — |
| R3 | Interações/UI/áudio | Backlog | — |
| R4 | Ferramentas de mapa | Backlog | — |
| R5 | Quests/Easter Eggs | Backlog | — |
| R6 | Escala de conteúdo | Backlog | — |
| R7 | Produção | Backlog | — |

> **Status:** nenhum código novo será escrito até o escopo da v2 ser aprovado.

---

# R0 — Preparação

**Objetivo:** arquivar a v1, criar a v2 e validar a base.  
**Aceite:** projeto v2 abre no Godot; assets presentes; regras de escopo aprovadas.

### Backlog
- [ ] Criar launcher “Bunker 13 v2 — Editor”
- [ ] Levantar inventário de assets reaproveitáveis
- [ ] Definir convenção de IDs (`map.*`, `weapon.*`, `quest.*`)

### Ready
- [ ] Revisar arquitetura-alvo e aprovar fases R1–R7
- [ ] Confirmar o que fica na v1 legada e o que é portado
- [ ] Reorganizar assets para a árvore híbrida
- [ ] Mover `.blend` para `source/blender/` com `.gdignore`

### Doing
- *(vazio — aguardando aprovação)*

### Review/Test
- [ ] Abrir `zombie-fps-v2` no Godot e validar importação
- [ ] Validar `project.godot` e autoloads (`Events`, `Content`, `Sfx`)

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
- [ ] DTOs tipados: `MapDefinition`, `WeaponDefinition`, `ExplosiveDefinition`, `MeleeDefinition`
- [ ] `ContentRegistry` + loader JSON + IDs
- [ ] JSON schemas + `ContentValidator` (referências, IDs, ciclos)
- [ ] `Bunker13Builder` lendo `MapDefinition`
- [ ] Converter Bunker 13 + 5 armas para JSON
- [ ] JSON de faca, granada, foguete, barris e traps
- [ ] Pipeline Blender de armas/mãos (todas as armas + mãos separadas)
- [ ] Validação de assets (paths + importação)
- [ ] Testes de definições e validação

### Doing
- *(vazio)*

### Review/Test
- [ ] Validar Bunker 13 por JSON
- [ ] Rodar `CONTENT_OK` e `LOGIC_OK`

### Done
- *(vazio)*

### Blocked
- *(vazio)*

---

# R2 — Loop de gameplay

**Objetivo:** paridade do loop + combate com explosivos e faca.  
**Aceite:** Bunker 13 jogável; armas usam JSON + `HandsRig`; faca e explosivos funcionando.

### Backlog
- [ ] Perk “Gatilho Duplo” com definição
- [ ] Estatísticas de sessão

### Ready
- [ ] `PlayerController` (movimento, vida, câmera)
- [ ] `WeaponController` (2 slots, hitscan/projectile/melee)
- [ ] `ExplosionSystem` (raio, LOS, falloff, impulso, cadeia)
- [ ] Granada (G), lança-foguete e barris explosivos
- [ ] `MeleeController` (V, corte diagonal, lunge, cooldown)
- [ ] Faca GLB + mãos compartilhadas + `knife_slash`
- [ ] `HandsRig` + cache de mãos + `grip_profile`
- [ ] `ViewmodelFactory` (armas GLB + mãos compartilhadas)
- [ ] `ZombieEnemy` com `EnemyDefinition`
- [ ] `RoundManager` (estado, spawn, escalonamento)
- [ ] `Economy` (pontos, compra, bônus)
- [ ] `Effects` (sangue, decais, tracers, cápsulas)
- [ ] Teste integrado do loop

### Doing
- *(vazio)*

### Review/Test
- [ ] Tiro/recarga de todas as armas; mãos reutilizadas; headshot
- [ ] IA, ataque sincronizado, morte e spawn
- [ ] Rodada 1 → 2 e game over

### Done
- *(vazio)*

### Blocked
- *(vazio)*

---

# R3 — Interações, UI e áudio

**Objetivo:** paridade de conteúdo e apresentação.  
**Aceite:** portas, wallbuys, caixa, perks, explosivos/faca, HUD, pause e áudio funcionando.

### Backlog
- [ ] Ajustes de mixagem
- [ ] Acessibilidade (tamanho de fonte/contraste)

### Ready
- [ ] `InteractionSystem` tipado
- [ ] Portas, wallbuys, caixa e perks
- [ ] Traps explosivas e props explosivos do JSON do mapa
- [ ] VFX/SFX de explosão/faca e HUD de granadas
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
