# Revisão de linha de base da Etapa 3 — Gameplay

**Data:** 2026-11-06  
**Escopo:** estado após a Etapa 2 — Conteúdo (repo limpo e publicado), antes de iniciar a Etapa 3 — Gameplay.  
**Método:** três subagentes somente leitura (`explorer`, `test-reviewer` e
`content-checker`) + CI local.

## Resultado

- CI verde: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `SLICE_OK`, `CI_OK`.
- Conteúdo formalmente válido: 2 mapas, 5 armas, 1 inimigo e 9 barricadas.
- **Mas o loop real ainda é o slice hardcoded.** O Bunker 13 é geometria +
  metadados; não é jogável de ponta a ponta.

## Atualização pós-revisão

- `--map <id>` + `MapBuilderRegistry`: o builder agora vem do JSON.
- Interações base implementadas: porta, wallbuy, perk e caixa.
- `GameRoot` usa `map.enemy_id` e `map.zombie_count`.
- `WeaponController` lê `audio` e `scale` do JSON.
- CI ganhou o smoke do Bunker 13 (`MAP_OK`) com compras.
- Blender + fontes `.blend` de todos os modelos.
- Geometria do mapa migrada para GLB autoral; builders antigos em
  `src/maps/legacy/` apenas para exportação.
- Continuam abertos: janelas/barricadas/IA, `hands.glb`, 2 slots e o teste de
  integração com falsos positivos.

## P0 — bloqueiam a Etapa 3 — Gameplay

| # | Achado | Evidência | Ação |
|---|---|---|---|
| 1 | O teste do Bunker 13 não podia falhar: `check()` só imprimia e o script sempre saía com `quit(0)`. | `tests/run_map_build.gd:3-7,30-31` | **Corrigido:** contador, `FAIL` em stderr e `quit(1)` |
| 2 | `GameRoot` fixa `map.slice` e `SliceBuilder`; não existe `--map`. | `src/gameplay/game_root.gd:23,30` | **Corrigido:** `--map` + `MapBuilderRegistry` |
| 3 | A interação só trata `door1`; wallbuy, perk, caixa e barricada não funcionam. | `src/gameplay/game_root.gd:139-163` | **Parcial:** porta/wallbuy/perk/caixa; falta barricada |
| 4 | O perímetro do Bunker 13 não tem vãos de janela; as barricadas são tábuas sem colisão e ficam ~0,18 m dentro da parede. | `src/maps/bunker13/builder.gd:144-148,229-241`; `content/maps/bunker13.json:34-42` | Abrir janelas e reposicionar barricadas |
| 5 | Não existe `Barricade`/`BarricadeSystem`, hold F, reparo, tear ou climb. | `BarricadeData` sem consumidor | Implementar o sistema |
| 6 | O zumbi só persegue e ataca; não há estados de janela. `zombie_count` já é usado, mas `spawn_position` é ignorado. | `src/gameplay/enemies/zombie_enemy.gd:93-126`; `src/maps/bunker13/builder.gd:20` | IA `approach/tear/climb` |
| 7 | `hands.glb` não existe. `hands`, `viewmodel` e `moving_parts` do JSON são ignorados. | `src/gameplay/player/weapon_controller.gd:37-58,143` | **Parcial:** áudio/escala vêm do JSON; faltam hands e viewmodel completo |
| 8 | Não há 2 slots: um único `WeaponController`; `weapon_changed` nunca é emitido. | `src/gameplay/player/player_controller.gd:60-64`; `src/core/event_bus.gd:14` | Inventário de 2 slots |
| 9 | O teste de integração tem falsos positivos: pontos por acerto, spawn incondicional e reload forçado. | `src/gameplay/game_root.gd:176-202` | Testar morte, kill, porta e recarga reais |

## P1 — dívida que atrapalha a Etapa 3 — Gameplay

- Builders duplicados: `SliceBuilder` vs `Bunker13Builder`
  (`src/maps/slice/slice_builder.gd:23-54` vs `src/maps/bunker13/builder.gd:37-74`);
  `build()` retorna dicionários com chaves diferentes.
- Geometria hardcoded (altura 3.4/3.2) ignora `rooms`/`height` do JSON.
- `get_child(0)` frágil para obter o `StaticBody3D` da porta
  (`src/maps/bunker13/builder.gd:159`).
- Spawns duplicam `barricade.spawn_position` e ficam dentro da sala
  (`content/maps/bunker13.json:22-32`).
- HUD fixa "SLICE" e "GLOCK 17"; não há barra de reparo
  (`src/gameplay/ui/hud.gd:125,137,172`).
- `ContentValidator` não checa `schema_version`, IDs duplicados, `hands`,
  áudio existente, `moving_parts` nem alcançabilidade.
- DTOs indexam arrays sem verificar tamanho (`src/content/map_data.gd:22-23`,
  `src/content/barricade_data.gd:20-29`).
- A contagem fixa de 5 armas quebrará ao adicionar faca/granada
  (`tests/run_logic_tests.gd:23-24`).
- Sem sons de barricada, faca ou explosão (`src/audio/sfx.gd`).
- Leaks de `ObjectDB`/recursos no CI; não bloqueiam, mas mascaram problemas.

## P2

- Teste visual do Bunker 13 ausente; o builder usa `randf_range`
  (`src/maps/bunker13/builder.gd:238-239`), então não é determinístico.
- `assets/models/weapons/pistol/pistol.glb` órfão; `wunder.json` não é
  referenciado por mapa ou caixa.
- **Resolvido:** fontes `.blend` criadas para as 5 armas, zumbi e pistol, com
  `overview.blend`. Falta migrar a geometria do mapa para cena autoral.
- Validação de nós móveis/animações ainda incompleta.

## Ordem recomendada

1. **Harness + `--map` + GameRoot/builder genéricos** (P0 1-3).
2. **Bunker 13 jogável:** janelas, barricadas, hold F, spawns externos e IA
   `tear/climb` (P0 4-6).
3. **Interações genéricas** (porta/wallbuy/perk/caixa/barricada) e HUD de reparo.
4. **`hands.glb` + `HandsRig`/`ViewmodelFactory`**; só então MP5, áudio por arma
   e 2 slots (P0 7-8).
5. Endurecer validador/testes e eliminar falsos positivos (P0 9, P1).

## Decisão

- A base de conteúdo está **OK**; a arquitetura de gameplay **não está pronta**
  para a Etapa 3 — Gameplay.
- **Não começar por MP5:** ela depende de `hands.glb` e de um viewmodel
  data-driven.
- Primeiro item da Etapa 3 — Gameplay: harness de testes + `--map` + generalização mínima do
  `GameRoot`.
- A revisão confirma o item já registrado ("Bunker 13 jogável") e promove o
  harness de testes a P0.

## Observação sobre os agentes

- Os três subagentes atingiram o limite de passos; para revisões amplas,
  aumentar `steps` para ~28.
- Nenhum arquivo foi alterado pelos agentes (somente leitura).
- O harness corrigido foi validado com uma falha forçada: `FAIL 4 portas`,
  `BUNKER13_FAIL 1`, exit `1`.
