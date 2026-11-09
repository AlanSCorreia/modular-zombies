# Retrospectiva — Bunker 13 v2

**Data:** 2026-11-09  
**Escopo:** projeto completo, da preparação ao release `etapa8` + correções pós-release.  
**Método:** métricas de `metrics/aggregates/`, GitHub, git, CI e leitura do
`19-decision-log.md`/`20-work-log.md`. Números completos em
`metrics/aggregates/retrospective.md`.

## Números-chave

| Métrica | Valor |
|---|---|
| Período | 2026-11-06 → 2026-11-09 |
| Commits | 119 |
| Issues | 49 (48 fechadas, 1 aberta) |
| Tags | `etapa1`…`etapa8` |
| Decisões registradas | 60 |
| Docs de planejamento | 23 |
| Gates de CI esperados | 43 |
| Código GDScript | 60 arquivos / 5.603 linhas |
| Testes | 11 arquivos / 1.970 linhas |
| Scripts Blender | 22 arquivos / 2.648 linhas |
| Conteúdo | 4 mapas, 9 armas, 2 inimigos, 4 quests |
| Assets | 21 GLBs, 22 `.blend`, 52,4 MB |
| Sessões de IA | 21 |
| Tokens de trabalho | 17,0 M (+1,07 B de cache read) |

O lead time médio das issues foi **0,1 dia**; o mediano, **0,0 dia**. Isso
reflete o modo de trabalho com agentes em sessões curtas, não um processo de
equipe tradicional.

## Decisões boas

1. **Conteúdo em JSON + DTOs + validador.** Permitiu criar mapas, armas,
   inimigos e quests sem tocar no núcleo; `NO_CORE_OK` e `CONTENT_OK` protegem
   o contrato.
2. **Geometria autoral em Blender → GLB.** Nada de geometria 3D em runtime;
   mapas, armas e props têm fonte `.blend` e passam por importação validada.
3. **`hands.glb` compartilhado + `ViewmodelFactory`.** Uma única mão para todas
   as armas, sem duplicação de asset.
4. **CI com gates + docs + métricas.** 43 gates, `check_docs`, snapshots de
   métricas e issues/milestones deram rastreabilidade acima da média.
5. **Decision log e work log.** As 60 decisões e 14 entradas permitem reconstruir
   o porquê das escolhas; isso salvou tempo em retomadas de contexto.
6. **Kino e geração variada.** Portas `open`/`requires_power`, ambiente por mapa,
   colisão trimesh e seleção dinâmica no menu quebraram o padrão “todos os mapas
   iguais”.
7. **Skills/agentes da comunidade.** GodotPrompter reduziu prompt próprio e
   trouxe 59 skills Godot validadas; o revisor encontrou problemas reais.
8. **Release com soak, licenças e checksums.** O processo de release foi
   auditável, mesmo com atrasos.

## Decisões ruins ou mistas

1. **`GameRoot` como god object.** 440 linhas e responsabilidades demais:
   mapa, player, HUD, economia, rodadas, quests, save/load, energia e
   interações. Foi o maior hotspot de churn (1.314 linhas alteradas).
2. **Estado global estático.** `GameFlow` com flags independentes causou o bug
   #46 (R na virada reiniciava no mapa de teste). `Events`/`Content`/`Sfx`
   simplificam, mas escondem dependências.
3. **`MapNav` BFS 2D + colisão AABB.** Funciona para mapas planos, limita
   verticalidade, rampas e desvios de obstáculos. Navmesh ficou como dívida.
4. **Testes monolíticos e gates que passavam falsamente.** `test_runner.gd`
   (1.391 linhas) concentra integração; `TRAP_OK`, `SOAK_OK`, `PERF_OK` e
   `NO_CORE_OK` foram endurecidos só depois da auditoria.
5. **JSON Schema não aplicado de ponta a ponta.** Os schemas existem, mas o
   runtime valida via DTO/validador manual; contratos de nós (`Door_`, `Plank_*`)
   continuam implícitos.
6. **UI/foco/input atrasados.** Falta de Input Map próprio, foco em pause/game
   over e tratamento de alt-tab só apareceram na auditoria final.
7. **Performance sem gate de GPU.** `PERF_OK` é headless; draw calls/GPU ficam no
   `bench.sh` manual. O orçamento não bloqueia regressão de render no CI.
8. **Release cedo demais em relação ao conteúdo.** A tag `etapa8` foi publicada
   antes de Kino e das correções; os artefatos publicados ficaram defasados.
9. **Placeholders de arte por tempo demais.** As armas só foram remodeladas
   depois de feedback; o primeiro resultado visual era fraco.
10. **Auditoria tardia.** Os achados de save/load, explosão, UI e testes
    apareceram no fim; revisões por subagentes poderiam ter rodado antes de
    cada etapa.

## O que os números mostram

- **Churn alto em `GameRoot`, HUD e `test_runner`** confirma que esses são os
  pontos de maior risco de manutenção.
- **5 commits `fix:` (4,2%)** é um número baixo, mas as correções foram
  concentradas no fim e em áreas críticas.
- **17 M tokens de trabalho / 48 issues fechadas** (~354 k por issue) mostra
  custo relevante de contexto e iteração; cache read de 1,07 B indica muita
  repetição de contexto.
- **49 issues em 4 dias** mostra velocidade alta, mas também pressão para
  fechar escopo; várias dívidas ficaram para #44.

## Dívidas que ficaram

- Arte final dos modelos e animações dedicadas (autor vai fornecer).
- Navmesh, pool de VFX, localização, controle, mods e escala de UI (#44).
- `GameRoot` e `test_runner` ainda pedem refatoração estrutural.
- Schemas JSON e contratos de nós ainda não são totalmente executáveis.
- Release publicada não inclui Kino/correções; precisa de novo build/versão.

## Conclusão

O projeto entregou um jogo jogável, buildável e com processo acima do normal
para um projeto solo/assistido por IA. As melhores decisões foram **conteúdo
data-driven, assets autorais e rastreabilidade**. As piores foram **concentrar
tudo no `GameRoot`, adiar input/performance/testes reais e publicar antes de
fechar conteúdo**.

Para o próximo projeto, o caminho é começar com serviços pequenos, schema
validado no CI, Input Map desde o dia 1, orçamento de performance bloqueante e
uma revisão por etapa — não só no fim. O playbook está em
[`../PLAYBOOK-NEXT.md`](../PLAYBOOK-NEXT.md).
