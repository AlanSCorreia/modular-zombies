# Auditoria curta de redundância

**Data:** 2026-11-07  
**Issue:** #15  
**Escopo:** documentação, CI, código e execução. Sem mudanças de gameplay.

## Método

- Contagem de arquivos/linhas e chaves de gate em `*.md`.
- Blocos duplicados de 5 linhas em `src/**/*.gd` (ignorando linhas triviais).
- Histórico Git: commits de feature vs. docs e arquivos tocados por bloco.
- Cronometragem dos 19 processos do `tests/ci.sh` (1 boot + 3 scripts +
  15 casos de cena), em 2026-11-07.
- Comparação KANBAN × issues abertas no GitHub.
- Sem telemetria de agente: leituras de arquivos por bloco são estimadas pela
  regra do `AGENTS.md`.

## Números

### Documentação

| Métrica | Valor |
|---|---:|
| Arquivos `.md` | 31 |
| `KANBAN.md` | 404 linhas |
| `20-work-log.md` | 360 linhas |
| `06-backlog.md` | 176 linhas / 111 itens |
| Checkboxes abertos no KANBAN | 80 |
| Gates distintos repetidos | 7 |
| Ocorrências de `LOGIC_OK` em docs | 16 (9 arquivos) |
| Ocorrências de `MAP_OK` em docs | 18 (8 arquivos) |
| Linhas longas idênticas entre docs | 8 linhas / 19 ocorrências |
| Itens em Ready com issue no GitHub | 2 de 12 (17%) |

O volume de linhas duplicadas literalmente é baixo. A redundância real é
**semântica**: o mesmo estado aparece em KANBAN (Ready/Done/Review), roadmap
(“entregue/pendente”), backlog (`feito`), work log, decision log e issue
fechada. Cada bloco recente tocou **4–9 arquivos de documentação**.

### Commits e execução

| Métrica | Valor |
|---|---:|
| Commits de docs | 36 |
| Commits de feature/outros | 22 |
| Proporção de commits só de docs | 62% |
| Últimos 12 commits | 7 docs / 5 feature |
| Commits por bloco | ~2 (feature + docs) |
| Arquivos de doc por bloco | 4–9 |
| Leitura obrigatória de planejamento | ~6 arquivos/bloco (`AGENTS.md`) |

### CI

| Métrica | Valor |
|---|---:|
| Processos Godot por execução | 19 |
| Casos de cena | 15 |
| Scripts headless | 3 |
| Boot isolado (`--quit`) | 1,12 s |
| Tempo total dos 19 processos | 38,3 s |
| Soma aproximada só de boots | ~21 s (55%) |
| Casos mais caros | `slice` 5,33 s; `viewmodel` 3,98 s; `softlock` 3,80 s; `zombie_barricade` 3,32 s |

O isolamento por processo é bom para diagnóstico, mas 15 boots repetem
importação/carregamento de conteúdo a cada gate.

### Código

| Métrica | Valor |
|---|---:|
| Arquivos `.gd` | 43 |
| Linhas `.gd` | 3.768 |
| Blocos de 5 linhas duplicados | 40 |
| Blocos duplicados fora de `src/maps/legacy` | **1** |
| Strings de prompt duplicadas | praticamente zero (1 ponto de emissão) |

**39 dos 40 blocos duplicados** são `MapSceneBuilder` × builders legados
(`src/maps/legacy/`), que existem só para exportar GLB. A duplicação de runtime
é baixa; os DTOs repetem o padrão `from_dict`, mas de forma previsível.

## Diagnóstico

1. **A documentação é o maior custo de execução.** Não por linhas, mas por
   repetir o mesmo estado em 5–6 lugares e exigir sincronização manual.
2. **O CI gasta mais da metade do tempo em boot.** 19 processos para 38 s de
   suíte é aceitável hoje, mas escala mal quando entrarem mais mapas/armas.
3. **O código de gameplay tem pouca duplicação real.** O número bruto (40
   blocos) engana: quase tudo é builder legado de exportação.
4. **KANBAN e GitHub divergem.** 10 dos 12 itens de Ready não têm issue; o
   board local vira uma segunda lista de tarefas.
5. **O work log cresce sem rotação.** 360 linhas é baixo, mas a tendência é
   dobrar por etapa.

## Recomendações

| # | Ação | Ganho estimado | Risco |
|---|---|---|---|
| 1 | Fonte única de status: issue + KANBAN. Roadmap/backlog guardam escopo, não “feito”. | −2 a −4 arquivos e ~25–35 linhas por bloco | Baixo |
| 2 | Criar suíte agrupada (`--case mechanics`) reutilizando um processo para casos locais; manter matriz completa no CI/nightly. | ~35–45% do tempo de CI local (38 s → ~22 s) | Médio (perde isolamento) |
| 3 | Criar issues para os itens de Ready ou removê-los; manter Ready ≤ 5. | Menos duplicação KANBAN/GitHub | Baixo |
| 4 | Arquivar/remover builders legados quando a regeneração de mapas não precisar mais deles. | Remove 39 dos 40 blocos duplicados | Médio (perde ferramenta de export) |
| 5 | Rotacionar o work log por etapa (`20-work-log-2026-11.md`). | Mantém o arquivo navegável | Baixo |
| 6 | Não unificar DTOs agora. | Evita abstração prematura | — |

## O que não mudar

- Gates separados no CI oficial: o custo de 38 s é aceitável e o diagnóstico
  por gate vale mais que a economia.
- Dois commits por bloco (feature + docs): facilita revisão e rollback.
- `ExplosionSystem`, `BarricadeSystem` e `ViewmodelFactory`: centralização já
  eliminou a duplicação de gameplay.

## Conclusão

A redundância **não está no código de jogo**; está no processo de
sincronização de status e no boot repetido dos testes. As ações 1–3 são de
baixo risco e podem entrar nos próximos blocos sem alterar gameplay. As ações
4–5 ficam para quando doerem de verdade.
