#!/usr/bin/env bash
# Snapshot de métricas do projeto. Rode no fim de cada bloco.
# O raw é privado/ignorado; os agregados em metrics/aggregates são versionáveis.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

python3 tools/export_history.py --with-github --with-comments
python3 tools/metrics.py
