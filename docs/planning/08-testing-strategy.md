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

## Portões por fase

| Fase | Portão |
|---|---|
| R0 | Importa; docs/Kanban aprovados; Git/CI prontos |
| R1 | Bunker 13 por JSON; assets organizados; 0 refs quebradas |
| R2 | Loop jogável; explosivos, faca e barricadas testados |
| R3 | Interações, UI e áudio do plano |
| R4 | Criar/validar/testar mapa no editor |
| R5 | Música + main quest de 3 passos; grafo válido |
| R6 | 2º mapa/armas sem mudar núcleo |
| R7 | Build exportado; FPS ≥ 40; zero softlocks |

## Comandos

```bash
# Tudo: import + lógica + conteúdo + integração
./tests/ci.sh

# Performance
./tests/bench.sh

# Visual
./run.sh -- --ui     # tela inicial
./run.sh -- --shot   # gameplay
```

**Estado atual:** `LOGIC_OK`, `CONTENT_OK`, `SLICE_OK`.
**Bench:** 42–61 FPS, 135 draw calls, 66 MB (vsync/foco).

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
