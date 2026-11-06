# Revisão R1 — achados e recomendações

## Estado

- R1 concluído: assets de modelos reorganizados, 2 mapas, 5 armas, Bunker 13
  em JSON + `Bunker13Builder`.
- Testes: `LOGIC_OK`, `CONTENT_OK`, `BUNKER13_OK`, `SLICE_OK`, `CI_OK`.
- O **slice continua sendo o alvo jogável**. O Bunker 13 é construído e
  validado, mas ainda não tem gameplay completo.

## Achados

1. **Bunker 13 não é jogável ainda.** O builder monta geometria/interactables;
   spawns, portas e barricadas genéricos ficam para R2.
2. **Só a Glock está integrada.** MP5/M870/AK/Wunder têm GLB + JSON, mas sem
   mãos separadas, animações e viewmodel em jogo.
3. **Glock ainda tem mãos embutidas.** Migração para `hands.glb` é R2.
4. **Geometria duplicada.** `SliceBuilder` e `Bunker13Builder` repetem helpers
   de caixa/parede; extrair um `BoxBuilder` reduz drift.
5. **`GameRoot` fixa `map.slice`.** Falta seletor/CLI `--map` para testar
   Bunker 13 sem trocar código.
6. **Validação de arma ainda é superficial.** Confere stats/cena/grip, mas não
   nós (`Slide`, `Muzzle`), nem animações/impacto.
7. **Bunker 13 sem teste visual.** O teste só conta nós; um screenshot evitaria
   regressão de paredes/portas.
8. **`source/blender` sem `.blend`.** Só os GLBs exportados estão versionados;
   a fonte editável ainda falta.
9. **Barricadas são visuais no builder.** Não há buraco de janela nem lógica de
   tábuas/reparo (R2).

## Recomendações

### P0 (antes de modelar mais armas)
- Integrar **MP5** como segunda arma de ponta a ponta: GLB + JSON + `hands.glb`
  + animações + viewmodel + teste. Só depois modelar as outras.
- Adicionar `--map <id>` no `GameRoot`; manter `map.slice` como padrão.
- Adicionar teste visual do Bunker 13 (câmera fixa + screenshot).
- Manter o slice jogável; não trocar a cena principal para Bunker 13 ainda.

### P1
- Extrair `BoxBuilder`/helpers comuns dos dois builders.
- Validar nós móveis e animações no `ContentValidator`.
- Implementar barricadas/hold F no Bunker 13 (R2).
- Versionar `.blend` fonte em `source/blender`.

### P2
- Props/atmosfera completos do Bunker 13.
- Ferramentas de autoria (R4).
- Save/load de barricadas e progresso (R7).

## Decisão

**Não promover Bunker 13 a mapa principal até R2/R3.** O slice permanece o
golden path jogável; o Bunker 13 entra quando spawns, portas e barricadas
estiverem genéricos e testados.
