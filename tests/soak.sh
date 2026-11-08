#!/usr/bin/env bash
# Soak test headless. Uso: ./tests/soak.sh [segundos]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
SECONDS_TO_RUN="${1:-1800}"
cd "$DIR"
"$GODOT" --headless --path . res://tests/test_runner.tscn -- \
  --case soak --seconds "$SECONDS_TO_RUN" --map map.bunker13
