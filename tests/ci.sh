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

echo "== geometria runtime =="
if grep -nE 'BoxMesh\.new|MeshInstance3D\.new' src/maps/map_scene_builder.gd; then
  echo "FAIL: geometria de mapa criada em runtime"
  exit 1
fi
echo "ok"

echo "== mapa Bunker 13 =="
"$GODOT" --headless --path . --script res://tests/run_map_build.gd

echo "== smoke Bunker 13 =="
"$GODOT" --headless --path . -- --map map.bunker13 --smoke

echo "== pause =="
"$GODOT" --headless --path . -- --pause-test

echo "== interação =="
"$GODOT" --headless --path . -- --interaction-test

echo "== 2 slots =="
"$GODOT" --headless --path . -- --slots-test

echo "== integração =="
"$GODOT" --headless --path . -- --test

echo "CI_OK"
