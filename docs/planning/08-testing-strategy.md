# Estratégia de testes — v2

## Pirâmide

| Nível | Escopo | Ferramenta |
|---|---|---|
| Unitário | JSON, regras, economia, explosões, melee, quest graph | `tests/run_logic_tests.gd` |
| Integração | Cena real, portas, navmesh, tiro, compras | `--test` headless |
| Conteúdo | JSON schema, IDs, referências, ciclos, softlocks | `ContentValidator` |
| Paridade | Comparar v1 ↔ v2 | Checklist + testes |
| Visual | Spawn, armas, faca, explosivos, menus | `--verify`, `--weapon`, `--combat`, `--shot` |
| Performance | FPS, bake, memória | Benchmark por mapa |
| Manual | Game feel, áudio, input | Checklist de release |

## Portões por fase

| Fase | Portão |
|---|---|
| R0 | Projeto importa sem erro; docs/Kanban aprovados |
| R1 | Bunker 13 por JSON; assets organizados; 0 refs quebradas |
| R2 | Loop jogável; explosivos e faca testados |
| R3 | Paridade v1 + explosivos/faca |
| R4 | Criar/validar/testar mapa no editor |
| R5 | Música + main quest de 3 passos; grafo válido |
| R6 | 2º mapa/armas sem mudar núcleo |
| R7 | Build exportado; FPS ≥ 40; zero softlocks |

## Comandos

```bash
# Regras puras
./run.sh --headless --script res://tests/run_logic_tests.gd

# Integração
./run.sh --headless -- --test

# Conteúdo
./run.sh --headless --script res://tests/run_content_validation.gd

# Visual
./run.sh -- --verify
./run.sh -- --weapon
./run.sh -- --combat
./run.sh -- --shot
```

> Os comandos acima só existirão a partir de R1/R2; até lá a referência é a
> suíte da v1 em `../zombie-fps-legacy/tests/`.

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

## Paridade v1 → v2

Antes de trocar o launcher:

- [ ] Loop de rodadas idêntico em comportamento.
- [ ] Todas as armas: tiro/recarga com e sem bala no cano; mãos reutilizadas.
- [ ] Portas, wallbuys, caixa e perks.
- [ ] Granada, lança-foguete, barris explosivos e traps.
- [ ] Faca (V, corte diagonal, dano/cooldown).
- [ ] HUD, pause, game over e restart.
- [ ] Áudio e efeitos essenciais.
- [ ] Testes de lógica e integração verdes.

## CI

- Rodar lógica + integração + validador JSON em cada PR.
- Bloquear merge com conteúdo inválido.
- Rodar soak test noturno (30 min).
- Guardar relatório de FPS por mapa.
