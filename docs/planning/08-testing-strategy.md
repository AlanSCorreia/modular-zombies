# Estratégia de testes — v2

## Pirâmide

| Nível | Escopo | Ferramenta |
|---|---|---|
| Unitário | JSON, regras, economia, explosões, melee, quest graph | `tests/run_logic_tests.gd` |
| Integração | Cena real, portas, navmesh, tiro, compras | `--test` headless |
| Conteúdo | JSON schema, IDs, referências, ciclos, softlocks | `ContentValidator` |
| Aceite | Golden path por fase | Checklist + testes |
| Visual | Start, armas, HUD, slice | `--ui`, `--shot` |
| Performance | FPS, bake, memória | Benchmark por mapa |
| Manual | Game feel, áudio, input | Checklist de release |

## Portões por etapa

| Etapa | Portão |
|---|---|
| Etapa 1 — Preparação | Importa; docs/Kanban aprovados; Git/CI prontos |
| Etapa 2 — Conteúdo | Bunker 13 por JSON; assets organizados; 0 refs quebradas |
| Etapa 3 — Gameplay | Loop jogável; explosivos, faca, barricadas e workflow de arma testados |
| Etapa 4 — Interações | Interações, UI e áudio do plano |
| Etapa 5 — Ferramentas | Criar/validar/testar mapa no editor |
| Etapa 6 — Quests | Música + main quest de 3 passos; grafo válido |
| Etapa 7 — Escala | 2º mapa/armas sem mudar núcleo |
| Etapa 8 — Produção | Build exportado; FPS ≥ 40; zero softlocks |

## Comandos

```bash
# Tudo: import + lógica + conteúdo + integração
./tests/ci.sh

# Performance
./tests/bench.sh

# Visual e integração (cena de teste)
./run.sh res://tests/test_runner.tscn -- --case ui     # tela inicial
./run.sh res://tests/test_runner.tscn -- --case shot   # gameplay
./run.sh res://tests/test_runner.tscn -- --case smoke --map map.bunker13
```

**Estado atual:** `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `MAP_OK`,
`SOFTLOCK_OK`, `PAUSE_OK`, `INTERACT_OK`, `SLOTS_OK`, `SLICE_OK`.
**Bench (2026-11-06):** ~60 FPS, 16,6 ms, 83 draw calls, 67 MB (vsync/foco).

## Testes de geometria

- `src/maps/map_scene_builder.gd` não pode criar `BoxMesh`/`MeshInstance3D`
  (gate no CI).
- Todo mapa tem `scene` existente e `builder: "scene"`.
- Bunker 13 carrega >20 meshes e >20 corpos de colisão.
- `MAP_OK` cobre carga do GLB e compras.

## Testes de arma

- Conteúdo: schema, stats, cena, mãos, `GripSocket`, partes móveis.
- Asset: GLB importa, escala/origem/eixos, `Muzzle`/`EjectPort`.
- Animações: `fire`, `fire_last`, `reload_chambered`, `reload_empty`.
- Integração: tiro, headshot, recarga com/sem bala no cano, 2 slots.
- Visual: arma + mãos na tela; muzzle flash e recuo.
- Aceite do workflow: uma **segunda arma** criada sem código especial.

## Testes de barricada

- Unidade: clamp 0..max, pontos, tempo de reparo/arranque.
- Integração: reparar 6 tábuas → +60 pontos; zumbi arranca até 0 e entra.
- Interrupção: soltar F/dano cancela sem consumir tábua.
- Conteúdo: barricada com ID único, room válido e spawn válido.
- Performance: 8 barricadas + 20 zumbis.

## Validador de conteúdo

Deve falhar em:

- JSON inválido, `schema_version` ausente ou tipo errado.
- IDs duplicados ou vazios.
- Referências inexistentes (mapa, arma, perk, inimigo, quest).
- Passos órfãos, ciclos inválidos ou inalcançáveis.
- Recompensa sem origem.
- Passo que consome item único sem reposição.
- Mapa sem spawn jogável ou sem rota até o objetivo.

## Validação de assets

- Toda referência `res://` existe e importa.
- Nenhum `.blend` dentro de `assets/` (fonte em `source/`).
- Materiais, animações, texturas e áudio referenciados existem.
- Modelos têm escala/orientação esperadas pelo contrato.
- Licenças registradas em `CREDITS.md`/`third_party`.

## Testes por mapa

1. Carregamento (cena + definição).
2. Caminho crítico da main quest.
3. Softlock (passo pulado, item perdido).
4. Performance (FPS mínimo e tempo de bake).
5. Checklist visual (spawns, portas, wallbuys, HUD, explosivos).
6. Teste de explosivos do mapa (barris/traps) e cadeia.

## Golden path do slice

Antes de expandir conteúdo:

- [ ] Iniciar pelo menu.
- [ ] Atirar e recarregar (com e sem bala no cano).
- [ ] Matar o zumbi e ganhar pontos.
- [ ] Abrir a porta e spawnar o segundo zumbi.
- [ ] Reparar uma barricada com hold F e ganhar pontos.
- [ ] Ver o zumbi arrancar tábuas e entrar com 0.
- [ ] HUD/health/ammo/pontos corretos.
- [ ] Game over e restart.
- [ ] `ci.sh` verde e bench dentro do orçamento.

## CI

- Rodar lógica + integração + validador JSON em cada PR.
- Bloquear merge com conteúdo inválido.
- Rodar soak test noturno (30 min).
- Guardar relatório de FPS por mapa.
