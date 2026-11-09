---
kind: reference
area: execution
status: active
stage: 8
owner: docs
last_reviewed: 2026-11-09
---

# Análise negativa do projeto — 2026-11-09

> **Status:** correções aplicadas em `26-analysis-fixes.md`; riscos residuais
> listados lá.

## Método

Revisão somente leitura com 7 subagentes:

- 5× `godot-code-reviewer` com skills do GodotPrompter (`godot-code-review`,
  `gdscript-patterns`, `player-controller`, `physics-system`, `ai-navigation`,
  `state-machine`, `godot-ui`, `hud-system`, `scene-organization`,
  `godot-testing`, `save-load`, `audio-system`).
- 1× `content-checker` para JSON, schemas, assets e mapas.
- 1× `doc-keeper` para consistência de docs.

Nenhum código foi editado. O CI não foi reexecutado nesta análise; o último
estado conhecido era verde. Alguns agentes atingiram o limite de passos, então
`src/maps/legacy/*`, parte de `content/quests/*.json` e os scripts Blender não
foram revisados linha a linha.

## P0 — risco de softlock, perda de progresso ou erro crítico

1. **Save/load de rodada trava a progressão** — `src/gameplay/save_game.gd:130-136`.
   O load restaura `spawned`, `alive` e `complete`, mas não repovoa zumbis nem
   reemite `completed`. `alive` pode ficar maior que a população real e a rodada
   nunca avança; `complete=true` sem timer também trava. Corrigir salvando só
   `round_no` e reiniciando a rodada no load.

2. **Save/load perde portas compradas e energia** — `src/gameplay/save_game.gd:33-57,120-127`
   e `src/gameplay/game_root.gd:309-318`.
   O save grava só `powered`; não grava portas abertas e o load não seta
   `power_on`. Portas pagas somem; as demais `requires_power` ficam bloqueadas
   porque o switch já está `used`. Salvar ids de portas e reabrir no load.

3. **Explosão não fere o jogador e quebraria se a máscara fosse corrigida** —
   `src/gameplay/combat/explosion_system.gd:76,99` e
   `src/gameplay/player/player_controller.gd:298`.
   A máscara `4|16` exclui a layer 2 (jogador); ao incluir, a chamada
   `take_damage(dano, false, pos)` passa 3 argumentos para uma função de 1.
   Padronizar assinatura e incluir a layer do jogador.

4. **Barris e traps são atravessáveis** — `src/gameplay/props/explosive_barrel.gd:12-13`,
   `src/gameplay/props/explosive_trap.gd:17-18`,
   `src/gameplay/player/player_controller.gd:32-33` e
   `src/gameplay/enemies/zombie_enemy.gd:78`.
   Props ficam na layer 16 com `mask=0`; jogador (`1|4`) e zumbis (`1|2`) não
   colidem com eles. Usar layer própria de props sólidos nas masks dos
   personagens.

5. **Conteúdo inválido deixa a cena vazia sem saída** — `src/gameplay/game_root.gd:36-44`.
   Se mapa/arma/inimigo falham, `_ready()` faz `return` sem HUD, ambiente ou
   botão de menu. Qualquer regressão de JSON vira softlock total. Em falha,
   voltar ao menu ou exibir overlay de erro.

6. **`is_start_visible()` acessa nó liberado** — `src/gameplay/ui/hud.gd:110,221-226`.
   `hide_start()` faz `queue_free()` e `_start = null`; chamadas posteriores
   quebram com `Invalid get index 'visible' on null`. Manter o nó e só ocultar,
   ou guardar `_start != null`.

7. **Pause/game over não recebem foco de teclado/gamepad** — `src/gameplay/ui/hud.gd:101-105,213-231`.
   `show_pause()`, `show_start()` e `show_gameover()` não chamam `grab_focus()`;
   `CONTINUAR`, `REINICIAR` e `MENU` só funcionam com mouse. Falta foco inicial
   e devolução de foco ao fechar.

8. **ESC ignora o Input Map e sequestra eventos de UI** — `src/gameplay/ui/hud.gd:131-134`,
   `src/gameplay/ui/main_menu.gd:135-140` e `project.godot` (sem `[input]`).
   `_input()` compara `keycode` cru; não há ação de pause para gamepad e o ESC
   pode fechar o menu com o popup de qualidade aberto. Usar
   `_unhandled_input()` + ação `ui_cancel`/`pause`.

## P1 — bugs de gameplay, contratos e estados

9. **Tempo de recarga do JSON é ignorado** — `src/gameplay/player/weapon_controller.gd:235-248`.
   `_reload_total` usa o `length` fixo das animações (2,05/1,55 s), ignorando
   `reload_chambered/reload_empty`. A M870 recarrega em 1,55 s em vez de 3,0 s.

10. **Headshot do Brute é impossível** — `src/gameplay/enemies/zombie_enemy.gd:339-340`
    e `content/enemies/brute.json:13`.
    `head_height=1,8` contra cápsula fixa de 1,72 m; nenhum raio atinge o
    limiar. Derivar cápsula/limiar de `scale` e altura real.

11. **Pathfinding refaz BFS a cada frame quando o alvo é inalcançável** —
    `src/gameplay/enemies/zombie_enemy.gd:177`.
    `_path.is_empty()` dispara o recálculo mesmo antes do timer; em hordas,
    custo O(zumbis × BFS) por frame. Recalcular só no timer.

12. **Modelo nulo no tween de morte** — `src/gameplay/enemies/zombie_enemy.gd:357-361`.
    `_build_model()` pode retornar sem `model`; o lambda usa `model` sem guarda
    e o nó nunca é liberado. Guardar `if model != null` e garantir `queue_free`.

13. **Escala de arranque por rodada não é usada** — `src/gameplay/enemies/zombie_enemy.gd:54-58`
    e `src/gameplay/game_root.gd:184`.
    `setup_barricade()` recebe `p_round := 1` e o spawn nunca passa
    `round.round_no`; `tear_time_round_scale` fica inerte.

14. **Animação de arranque congela após a primeira tábua** —
    `src/gameplay/enemies/zombie_enemy.gd:148-155,252`.
    `_play("Attack")` retorna se `_anim_state` já é "Attack"; `_move_to` não roda
    no estado `BAR_TEAR`. Forçar replay da animação.

15. **`alive` só cai em `notify_killed`** — `src/gameplay/round_manager.gd:57-70`.
    Despawn/kill-plane/restore que não emitem `Events.zombie_killed` deixam
    `alive > 0` para sempre. Reconciliar com `game.zombies.size()` ou decrementar
    em `tree_exited`.

16. **Ondas sempre usam barricadas quando existem** — `src/gameplay/round_manager.gd:87-103`.
    `_spawn_wave()` retorna após barricadas e ignora `map.zombie_spawns`; se a
    IA travar no spawn externo, a onda não termina. Intercalar ou cair para
    spawns internos.

17. **Porta sem geometria é cobrada e tweena `null`** —
    `src/maps/map_scene_builder.gd:103-117` e `src/gameplay/game_root.gd:266-275`.
    `door.node`/`door.body` podem ficar nulos; `_buy_door()` cobra e chama
    `tween_property(node, ...)`. Validar antes de cobrar.

18. **`quest_step` é emitido duas vezes** — `src/gameplay/quests/quest_system.gd:78-80,127`.
    `notify()` emite e `_announce_step()` emite de novo; banner/step duplicado
    e contagem dupla em listeners. Emitir em um lugar só.

19. **Reparo de barricada pode farmar pontos** — `src/gameplay/interaction/barricade_system.gd:46-69`.
    `repair_tick` pode reparar várias tábuas no mesmo frame com `delta` grande e
    `repair_one` paga mesmo se outra chamada já encheu. Limitar 1 tábua/tick e
    revalidar antes de pagar.

20. **Estado estático do `GameFlow` pode dessincronizar** — `src/core/game_flow.gd:7-8`,
    `src/gameplay/game_root.gd:29-38` e `src/gameplay/ui/main_menu.gd:119-130`.
    `auto_start` e `selected_map` são flags independentes; `change_scene_to_file`
    ignora o retorno. Se a cena falhar, as flags ficam armadas para a próxima
    entrada. Encapsular em um request atômico e checar o `Error`.

21. **Save de armas falha em silêncio e perde slot ativo** —
    `src/gameplay/save_game.gd:95-109`.
    Ids inexistentes são ignorados; `active_slot` não é salvo; se todas falharem,
    `player.weapon` fica `null` e o load retorna `true`. Registrar erro e cair
    para a arma inicial.

22. **Clamps ausentes no load** — `src/gameplay/save_game.gd:86-90`.
    Vida, granadas e pontos entram sem clamp; `health <= 0` ou acima do máximo
    gera estado inválido. Validar/clamp e tratar vida zero como game over.

23. **`MapArgs` não consome o override quando `--map` é usado** —
    `src/core/map_args.gd:11-17`.
    O arquivo `user://playtest.cfg` fica para trás e a próxima execução sem args
    pula para o mapa antigo. Consumir/limpar sempre.

24. **`ContentRegistry` aceita ID duplicado, ignora versão e não bloqueia conteúdo parcial** —
    `src/core/content_registry.gd:39-62`.
    Um arquivo sobrescreve outro em silêncio; `schema_version` não é validado;
    `loaded` não é usado para impedir o start. Adicionar detecção de duplicata,
    versão e gate de boot.

25. **DTOs indexam arrays sem checar tamanho e schemas não são aplicados** —
    `src/content/map_data.gd:34-35`, `src/content/door_data.gd:19-22`,
    `src/content/room_data.gd:11-12` e `schemas/map.schema.json:18-27`.
    Array curto aborta `reload()` no meio; `run_content_validation` pode passar
    com `errors` vazio. Validar `size()` e rodar JSON Schema no CI.

26. **Loop de áudio compartilhado e player órfão** — `src/audio/sfx.gd:103-105,241-254`.
    `amb.loop = true` muta o stream cacheado usado por `music.bunker13`;
    `play_music()` nunca recebe `finished` em loop e deixa player órfão.
    Duplicar o stream ou usar `_music` para loops.

27. **Perda de foco não pausa nem libera o mouse** — `src/gameplay/game_root.gd:144`.
    Alt-tab mantém `MOUSE_MODE_CAPTURED` e a partida roda; o jogador toma dano
    sem controle. Pausar em `NOTIFICATION_APPLICATION_FOCUS_OUT`.

28. **Game over não pausa o mundo** — `src/gameplay/game_root.gd:364-369`.
    Zumbis e física continuam atrás do overlay de morte; F5/F9 seguem ativos.
    Pausar a árvore ou congelar o mundo no game over.

## P2 — gates de teste que podem passar falsamente

29. **`_trap` força a detonação** — `tests/test_runner.gd:745-749`.
    Se o gatilho de proximidade não disparar, o teste chama `trap.detonate(0)`
    e marca `detonated=true`; `TRAP_OK` não prova o gatilho. Remover o fallback.

30. **`PERF_OK` roda headless com uma amostra** — `tests/test_runner.gd:1274-1282`.
    Renderer dummy não mede GPU/draw calls e uma leitura única pode passar/falhar
    por pico. Medir em execução real e usar baseline/percentil.

31. **`SOAK_OK` sempre retorna true** — `tests/test_runner.gd:1284-1301`.
    Não verifica memória, nós órfãos nem `iterations > 0`. Comparar
    `MEMORY_STATIC`/`OBJECT_COUNT` início/fim e exigir iteração.

32. **`NO_CORE_OK` passa se não escanear nada** — `tests/run_no_core_test.gd:22-25`.
    `DirAccess.open` nulo faz `return` silencioso. Contar `.gd` visitados e
    tratar falha de diretório como erro.

33. **Import do CI não é verificado** — `tests/ci.sh:15-16`.
    `--import` grava em `/tmp/bunker_import.log` e imprime `ok` sem grepar erros.
    Falha de parse/import só aparece depois, de forma confusa. Usar
    `TMPDIR` e falhar em `SCRIPT ERROR|ERROR`.

34. **`check_docs` valida a lista de gates contra ela mesma** —
    `tools/check_docs.py:192-227`.
    Remover um passo do `ci.sh` mantém `DOCS_OK` verde e o gate anunciado.
    Cruzar cada gate com o `_OK` realmente impresso e a invocação no CI.

35. **Contagens fixas no teste de lógica** — `tests/run_logic_tests.gd:29-33`.
    `maps==4`, `weapons==9`, `quests==4` quebram a cada adição legítima e
    incentivam atualizar o número sem investigar. Testar invariantes/IDs.

36. **`run_map_tools` escreve em `res://tests/tmp_maps`** —
    `tests/run_map_tools.gd:3,7,29-32`.
    Checkout read-only ou falha no meio suja a árvore; o retorno de
    `make_dir_recursive_absolute` e a limpeza não são checados. Usar `user://`
    ou `TMPDIR`.

## Documentação e conteúdo

37. **CREDITS sem Kino** — `CREDITS.md:24` lista só `slice`, `bunker13` e
    `depot`; o mapa Kino não aparece. Incluir a recriação autoral.

38. **`reference.md` ausente em 4 armas** — `CREDITS.md:27` afirma que toda arma
    tem referência, mas faltam `glock17`, `sks`, `raygun` e `knife`.

39. **Asset documentado que não existe** — `docs/planning/11-assets.md:90` cita
    `models/props/barricade_plank.glb`, mas o arquivo não está em
    `assets/models/props/`; o runtime usa `Plank_*` embutido nos mapas.

40. **Ray Gun com contrato ambíguo** — `content/weapons/raygun.json:12-13`.
    Declara `explosive: explosive.frag` (raio 4 m) e `projectile.explosion_radius: 0.0`;
    o projétil usa o explosivo e vira AoE de granada. Remover um dos contratos.

41. **Validador de quest usa união global de mapas** —
    `src/content/quest_validator.gd:13-36`.
    `enter_area: "C"`, `door1` e `radio_1` podem resolver contra outro mapa
    (há `door1` em três mapas). Vincular quest a mapa ou prefixar targets.

42. **Docs de estado desatualizados** — `KANBAN.md:258` (#27 em Ready e Done),
    `docs/planning/06-backlog.md:15-17` (#43 ainda pendente) e
    `06-backlog.md:115` ("Etapa 4 em andamento"),
    `docs/planning/14-weapon-workflow.md:23` (`-Z` frente vs `+Y` frente),
    `RELEASE_NOTES.md:14` e `24-release-checklist.md:34` (3 mapas, sem Kino),
    `02-architecture.md:31-39` (Etapa 3 em andamento), `20-work-log.md:144`
    (próximo #43). Corrigir após decidir o próximo bloco.

## Ordem recomendada de correção

1. Save/load de rodada, portas e energia; explosão contra o jogador; colisão de
   barris/traps.
2. UI: `is_start_visible`, foco de pause/game over, ESC por Input Map, game over
   pausado, perda de foco.
3. Gates que passam falsamente: trap, soak, perf, no-core, import do CI.
4. `ContentRegistry`/schemas e clamps de save.
5. Docs e contratos de conteúdo (Kino, reference.md, raygun, quests).

Nenhuma dessas correções foi aplicada nesta análise.
