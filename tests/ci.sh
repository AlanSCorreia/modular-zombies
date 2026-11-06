#!/usr/bin/env bash
# CI local: import + lógica + conteúdo + integração.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
cd "$DIR"

echo "== import =="
"$GODOT" --headless --path . --import >/tmp/bunker_import.log 2>&1
echo "ok"

echo "== lógica =="
"$GODOT" --headless --path . --script res://tests/run_logic_tests.gd

echo "== conteúdo =="
"$GODOT" --headless --path . --script res://tests/run_content_validation.gd

echo "== integração =="
"$GODOT" --headless --path . -- --test

echo "CI_OK"
