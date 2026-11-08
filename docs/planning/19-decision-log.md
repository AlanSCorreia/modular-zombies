---
kind: log
area: execution
status: active
stage: 3
owner: docs
last_reviewed: 2026-11-08
---

# Log de decisões

Registro durável de decisões que afetam arquitetura, escopo e pipeline.
Decisões estruturais longas também viram ADR em `07-adr/`.

| ID | Data | Decisão | Motivo / consequência |
|---|---|---|---|
| D-046 | 2026-11-08 | **Duas armas novas:** pistol normalizada para metros e SKS autoral entram por JSON/GLB, com shared hands, wallbuy e `WEAPONS_OK`; nenhum caso especial no núcleo. | Prova o contrato de armas para modelos novos e valida o wallbuy data-driven. |
| D-045 | 2026-11-08 | **Segundo mapa por composição:** `map.depot` reutiliza GLB/builder e adiciona mecânicas por JSON (`power_switches`/`radios`/quest), sem código específico de mapa no núcleo. | Prova a escala do framework e vira base para as armas novas. |
| D-044 | 2026-11-08 | **Etapa 6 aceita:** música secreta (3 rádios), PowerMechanic, QuestValidator e main quest de 3 passos fecham o aceite; debug overlay fica como dívida. Etapa 7 começa pelo segundo mapa. | Prova o framework de quests sem bloquear a escala por ferramentas de debug. |
| D-043 | 2026-11-08 | **QuestValidator:** valida referências de alvo, rewards, `next`, órfãos e ciclos; o grafo usa `next` explícito ou o próximo índice. | Impede quest quebrada/softlock antes do runtime e prepara branches futuros. |
| D-042 | 2026-11-08 | **PowerMechanic:** switch data-driven emite `power_on(id)`, acende luzes autoradas e abre a porta configurada sem custo; quest usa o trigger `power`. | Mantém a mecânica no mapa/JSON e evita hardcode de Bunker 13 no núcleo. |
| D-041 | 2026-11-08 | **Rádios data-driven:** `radios` no mapa viram `RadioState`/área; interação emite o evento padrão, marca uso único e a quest reage sem hardcode. | Mantém quests e interação desacopladas e permite qualquer mapa adicionar rádios. |
| D-040 | 2026-11-08 | **QuestSystem sequencial:** passos são avaliados na ordem; eventos fora de ordem são ignorados; recompensas são emitidas por sinal e aplicadas pelo `GameRoot`. | Evita softlock por eventos perdidos e mantém o sistema desacoplado de economia/arma/perk. |
| D-039 | 2026-11-08 | **Etapa 5 aceita:** create/duplicate, validador, playtest e quickstart cobrem o aceite; marcadores 3D/content browser ficam como dívida de ferramenta. Etapa 6 começa pelo `QuestSystem`. | Fecha a autoria de mapas sem bloquear quests por UI avançada. |
| D-038 | 2026-11-08 | **Playtest por mapa:** o dock grava `user://playtest.cfg`; `MapArgs` consome o override uma vez, mas `--map` continua tendo prioridade. | Permite testar o mapa selecionado no editor sem mudar o núcleo nem deixar estado permanente. |
| D-037 | 2026-11-08 | **Templates de mapa reutilizam a cena:** create/duplicate copiam/renomeiam apenas o JSON; a cena GLB de origem é reutilizada até o autor exportar a geometria própria. `MapTools` é headless e testável. | Evita copiar texturas/GLB e mantém o fluxo de autoria simples; a troca de cena é explícita. |
| D-036 | 2026-11-08 | **Etapa 4 aceita:** áudio por buses, volume persistido, stingers de rodada e VFX/SFX cobrem o aceite; vinheta/teste de UI ficam como polish. Etapa 5 começa pelo create/duplicate no `bunker_tools`. | Fecha a apresentação sem bloquear a autoria de mapas por polish visual. |
| D-035 | 2026-11-08 | **Feedback de combate:** explosão usa partículas/luz com mesh/material cacheados e SFX via pool; HUD de granadas é um label ligado a `grenades_changed`. | Evita alocação por explosão e mantém HUD desacoplada por sinal. |
| D-034 | 2026-11-08 | **Etapa 3 aceita:** rodadas escalam +2 a cada rodada, intervalo de 4 s e game over cancela a próxima; a normalização de escala (#16) fica como dívida visual e a Etapa 4 começa com traps/VFX/áudio. | Fecha o aceite de gameplay sem bloquear a apresentação por uma dívida de asset. |
| D-033 | 2026-11-08 | **Faca no viewmodel compartilhado:** o GLB da faca é anexado ao `HandR` do `hands.glb`; a mão esquerda é ocultada e o golpe é um viewmodel transitório com tween (`knife_slash`), sem lógica de dano duplicada. | Mantém uma única fonte de mãos e separa visual de hit detection. |
| D-032 | 2026-11-08 | **Métricas como calibração:** manter snapshot por bloco; usar 4–6 KPIs (lead time, tokens/bloco, retrabalho, churn de docs, tempo de CI, gates); instrumentar o próximo projeto desde o dia 1 e revisar por milestone. Não tratar tokens/linhas como medida de qualidade. | Evita overfitting de um único projeto e transforma o histórico em melhoria de workflow. |
| D-031 | 2026-11-08 | **Métricas do processo:** export somente leitura do SQLite do OpenCode + git + GitHub + CI para `metrics/raw/` (privado/ignorado); agregados em `metrics/aggregates/`; snapshot obrigatório no fim de cada bloco. | Permite medir tempo/tokens/retrabalho sem expor transcrições e mantém o histórico até o fim do projeto. |
| D-030 | 2026-11-08 | **Validação de docs em CI:** front matter obrigatório, `tools/check_docs.py` offline (links, índice, gates, KANBAN, work log, decisões, backlog), `--write` para blocos gerados e `--with-github` opcional com cache versionado. | Torna a consistência verificável sem acoplar o build ao GitHub; o cache cobre agentes offline. |
| D-029 | 2026-11-08 | **Taxonomia das docs:** `docs/planning/README.md` é índice; revisões históricas e log detalhado vão para `archive/`; `20-work-log.md` fica curto, mais recente primeiro e rotaciona por etapa; status continua em KANBAN + issues. | Reduz navegação e duplicação sem perder rastreabilidade. |
| D-028 | 2026-11-07 | **Política após auditoria de redundância:** KANBAN + issues são a fonte de status; roadmap/backlog não devem repetir “feito” além do necessário. CI oficial mantém gates isolados; suíte agrupada é opcional para uso local. Builders legados só saem quando a regeneração de mapas não precisar mais deles. | Reduz sincronização manual sem sacrificar diagnóstico por gate nem ferramenta de export. |
| D-027 | 2026-11-07 | **Mãos compartilhadas via factory:** um único `assets/models/hands/hands.glb` (`GripSocket`/`HandL`/`HandR`); `ViewmodelFactory` instancia arma + mãos e usa o `GripSocket` da arma ou o offset do `grip_profile`; validador exige `hands` compartilhado e perfil conhecido. | Cumpre a regra de um único asset de mãos, remove mãos embutidas da Glock e destrava MP5/faca sem duplicar modelos. |
| D-026 | 2026-11-07 | **Janelas por segmentos + IA de barricada:** paredes externas viram segmentos retangulares no `.blend` (peitoril/verga), com colisão por AABB; spawns usam `barricade.spawn_position` e o zumbi percorre `approach → tear → climb → inside`, com claim de fila no `BarricadeSystem` (`tear_time` escalado pela rodada). | Abre vãos reais sem colisão fantasma, mantém a geometria autoral e permite fila determinística por barricada. |
| D-025 | 2026-11-06 | **Barricadas no estado + sistema:** `BarricadeState` guarda `plank_count`/`repair_progress`/`breached` e liga os meshes `Plank_*`; `BarricadeSystem` roda hold F contínuo via `PlayerController.get_interactable()/is_interact_held()`, paga `repair_points`, cancela por dano/troca de arma e expõe `tear_plank()` para a IA. | Mantém o reparo testável e desacoplado da IA; a geometria autoral continua sendo a única fonte visual. |
| D-024 | 2026-11-06 | **Granada, foguete e barris data-driven:** granada com `fuse` de `ExplosiveData`; lança-foguete é arma `projectile` com `explosive`; barris vêm de `map.barrels` e disparam `ExplosionSystem`. | Conteúdo novo sem código específico; qualquer arma projétil pode reutilizar o mesmo explosivo. |
| D-023 | 2026-11-06 | **Explosão centralizada:** `ExplosionSystem` faz shape query com raio/falloff/LOS/limite, impulso em `RigidBody3D` e cadeia por grupo `explosive_chain` com `chain_depth`. | Um serviço evita duplicar regras em granada, foguete e barris. |
| D-022 | 2026-11-06 | **Armas por tipo:** `hitscan` (com pellets), `projectile` (classe `Projectile`) e melee separado (`MeleeController` + `melee.knife` JSON). | Um controller não acumula todos os tipos; dados de melee/projétil ficam no conteúdo. |
| D-021 | 2026-11-06 | **Serviços de loop:** `Economy` (pontos/compra) e `RoundManager` (ondas/spawn/conclusão) separados do `GameRoot`. | `GameRoot` só orquestra; testes e regras ficam isolados. |
| D-020 | 2026-11-06 | **HUD autoral:** `scenes/ui/hud.tscn` guarda a árvore; `hud.gd` só faz bind/sinais via `@onready`. | Ajuste visual sem rodar o jogo; corrige a dívida do HUD 100% em código. |
| D-019 | 2026-11-06 | **Pool/cache de efeitos:** áudio em pools fixos (12x 2D, 16x 3D), tracer com mesh/material estáticos e animação por mapa de estados + cache de cena. | Corta alocação por tiro/som/spawn sem mudar gameplay; bench atual estável. |
| D-018 | 2026-11-06 | **Harness em cena de teste:** `tests/test_runner.tscn` roda como cena principal (autoloads disponíveis) e instancia `main.tscn`; casos via `--case`. | Remove ~250 linhas de teste do `GameRoot` e mantém autoloads sem gambiarra em `--script`. |
| D-017 | 2026-11-06 | **`MapContext`/`Interactable` tipados:** `DoorState.open` é o único estado de porta; `kind` vira enum, não string. | Elimina `ctx: Dictionary`, `door_open` global e strings mágicas nos consumidores. |
| D-016 | 2026-11-06 | **Navegação por BFS de salas/portas** (`MapNav`, grafo de salas com arestas por porta; porta fechada bloqueia a aresta) em vez de navmesh para os zumbis; ondas só em salas alcançáveis. | 4 salas retangulares: BFS é determinístico, barato e impede pathing por portas fechadas; `path()` devolve waypoints pelas portas ou vazio (zumbi faz idle). Navmesh fica para mapas irregulares (Etapa 8). |
| D-015 | 2026-11-06 | **2 slots:** dois `WeaponController` independentes; arma comprada ocupa slot vazio, arma repetida troca e reabastece, slots cheios substituem o slot ativo. | Preserva munição/recarga por arma e evita duplicatas; wallbuy/caixa seguem a mesma regra. |
| D-014 | 2026-11-06 | **Mapas autorais em GLB:** runtime carrega `assets/models/maps/<id>/<id>.glb` e cria apenas colisão/áreas/labels. Builders antigos ficam em `src/maps/legacy/` para exportação. | Cumpre a regra de assets autorais e permite editar o mapa no Blender. |
| D-013 | 2026-11-06 | **Organização híbrida:** docs duráveis no repo; execução (issues/milestones) no GitHub; `KANBAN.md` é snapshot. O subagente `doc-keeper` mantém a consistência. | Dá histórico/notificações no GitHub sem perder o acesso offline dos agentes; evita duplicar status. |
| D-012 | 2026-11-06 | **Os docs definem a execução.** O próximo item é o `Doing` do Kanban; se vazio, o topo de `Ready` da etapa ativa. Não perguntar próximo passo ao usuário. | Evita interrupção e mantém o trabalho reproduzível. |
| D-011 | 2026-11-06 | **Nenhum modelo 3D em runtime.** Todo modelo tem `.blend` fonte em `source/blender/` e GLB em `assets/models/`. Mapas usam geometria autoral + JSON de âncoras. | Permite abrir/editar no Blender e evita geometria escondida em GDScript. |
| D-010 | 2026-11-06 | **Blender 4.5 LTS** é a ferramenta de modelagem. `./blender.sh` abre a visão geral. | Pipeline único para armas, inimigos, props e mapas. |
| D-009 | 2026-11-06 | **Migração da geometria do mapa é pré-requisito da Etapa 3**, não uma nova etapa. A Etapa 4 começa depois do aceite da Etapa 3. | Mantém a sequência estável e impede construir mais gameplay sobre geometria runtime. |
| D-008 | 2026-11-06 | **Nomenclatura por etapas:** `Etapa N — Nome` (`etapa1`…`etapa8`). IDs de tarefa `ETAPA3.1`. | Substitui `R0`–`R7` por nomes descritivos e ordem explícita. |
| D-007 | 2026-11-06 | **Subagentes de desenvolvimento** com escopo fechado: `explorer`, `test-reviewer`, `content-checker`. | Paraleliza exploração/revisão sem dar edição ampla a agentes. |
| D-006 | 2026-11-06 | **Sem LLM no runtime.** IA do jogo é determinística. | Latência, custo e não determinismo não se justificam. |
| D-005 | 2026-11-06 | **Mãos compartilhadas:** um único `hands.glb` para todas as armas, com poses por `grip_profile`. | Evita mãos duplicadas e mantém o viewmodel consistente. |
| D-004 | 2026-11-05 | **Conteúdo em JSON**; `.tres`/`.tscn` só para assets de engine. | Fonte de verdade auditável e validável. |
| D-003 | 2026-11-05 | **GDScript** em vez de C# até profiling comprovar gargalo. | Menor custo e iteração mais rápida; ver `07-adr/0001`. |
| D-002 | 2026-11-05 | **Reescrever a v2**; a v1 é apenas histórico. | Evita herdar dívida do protótipo. |
| D-001 | 2026-11-05 | **Arquitetura data-driven** com `ContentRegistry`, DTOs e validador. | Conteúdo autoral sem `if map_id` no núcleo. |

## Como registrar

- Decisão nova: adicionar linha no topo da tabela com ID `D-0NN`.
- Decisão estrutural: criar ADR curto em `07-adr/` e referenciar aqui.
- Avanço de execução: registrar em `20-work-log.md`, não aqui.
