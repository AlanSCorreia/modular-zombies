# Métricas do projeto

Objetivo: registrar o processo (prompts, respostas, ferramentas, decisões,
commits, issues, CI) para análise posterior e melhoria do próximo projeto.

## Estrutura

```text
metrics/
  raw/                    # privado; ignorado pelo git (metrics/.gitignore)
    sessions.jsonl
    messages.jsonl
    tool_calls.jsonl
    commits.jsonl
    issues.json
    ci.jsonl
    ci/*.log
    manifest.json
  aggregates/             # versionado
    summary.json
    per_session.csv
    per_day.csv
    per_issue.csv
```

## Snapshot (fim de cada bloco)

```bash
./tools/metrics_snapshot.sh
```

O script:
1. Lê o SQLite local do OpenCode em modo somente leitura.
2. Filtra apenas sessões de `/home/bababoi/zombie-fps-v2`.
3. Exporta mensagens, tool calls, tokens e tempos.
4. Junta `git log --numstat`, issues via `gh` e logs de CI.
5. Gera os agregados versionáveis.

`metrics/.gdignore` impede o Godot de importar os CSV como traduções.

Sem GitHub/rede:

```bash
python3 tools/export_history.py             # sem issues
python3 tools/metrics.py
```

## Privacidade

- `metrics/raw/` contém transcrições e **nunca** deve ser commitado.
- O exportador mascara tokens/segredos conhecidos e troca o caminho do
  projeto por `<project>`.
- Agregados (`aggregates/`) têm apenas contagens, tempos, tokens e labels.
- Sessões de outros diretórios são ignoradas pelo filtro de projeto.

## Métricas disponíveis

- `summary.json`: totais de sessões, mensagens, tool calls, tokens, commits,
  issues e gates de CI.
- `per_session.csv`: duração, mensagens, ferramentas e tokens por sessão.
- `per_day.csv`: atividade diária (mensagens, ferramentas, tokens, commits).
- `per_issue.csv`: lead time, labels, commits ligados e menções em docs.

## Limitações

- Custo monetário é 0 no provedor local; tokens são reais.
- Sessões antigas podem ter sido compactadas.
- O vínculo commit↔issue usa mensagens de commit e o work log; commits sem
  `#N` dependem do work log.
- Logs de CI só entram se existirem em `/tmp/opencode/ci_*.log` ou forem
  passados via `--ci-log`.

## Uso ideal (guia para projetos futuros)

1. **Baseline:** rode o snapshot no início e no fim de cada milestone.
2. **KPIs fixos (4–6):** lead time por issue, tokens/bloco, retrabalho
   (`fix`/CI vermelho), churn de docs, tempo de CI e gates por entrega.
3. **Instrumentar desde o dia 1:** banco/sessões, logs de CI e issues; não
   deixar para o fim.
4. **Revisão por milestone:** comparar números com o baseline e ajustar o
   workflow, não só acumular CSV.
5. **Calibração, não verdade:** tokens ≠ complexidade, linhas ≠ valor e tempo
   ≠ qualidade. Use junto com retrospectiva qualitativa.
6. **Amostra:** um projeto é baseline; evite overfittar antes de 2–3 projetos.
