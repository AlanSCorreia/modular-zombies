#!/usr/bin/env bash
# CI local: import + lógica + conteúdo + integração.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
cd "$DIR"

# Fonte única dos gates esperados (validado por tools/check_docs.py).
GATES="DOCS_OK LOGIC_OK CONTENT_OK TOOLS_OK PLAYTEST_OK BUNKER13_OK MAP_OK SOFTLOCK_OK PAUSE_OK INTERACT_OK SLOTS_OK MELEE_OK PROJECTILE_OK EXPLOSION_OK GRENADE_OK ROCKET_OK BARREL_OK BARRICADE_OK ZOMBIE_BARRICADE_OK VIEWMODEL_OK KNIFE_OK ROUNDS_OK TRAP_OK FX_OK AUDIO_OK QUEST_OK RADIO_OK SLICE_OK CI_OK"

echo "== docs =="
python3 tools/check_docs.py

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

echo "== ferramentas de mapa =="
"$GODOT" --headless --path . --script res://tests/run_map_tools.gd

echo "== playtest args =="
"$GODOT" --headless --path . --script res://tests/run_playtest_args.gd

echo "== smoke Bunker 13 =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case smoke --map map.bunker13

echo "== softlock Bunker 13 =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case softlock --map map.bunker13

echo "== pause =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case pause

echo "== interação =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case interaction

echo "== 2 slots =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case slots

echo "== melee =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case melee

echo "== projetil =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case projectile

echo "== explosão =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case explosion

echo "== granada =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case grenade

echo "== foguete =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case rocket

echo "== barris =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case barrel --map map.bunker13

echo "== barricadas =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case barricade --map map.bunker13

echo "== zumbi na barricada =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case zombie_barricade --map map.bunker13

echo "== viewmodel/mãos =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case viewmodel

echo "== faca =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case knife

echo "== rodadas =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case rounds

echo "== traps =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case trap --map map.bunker13

echo "== vfx/sfx =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case fx

echo "== áudio =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case audio

echo "== quest =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case quest

echo "== rádios =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case radio --map map.bunker13

echo "== integração =="
"$GODOT" --headless --path . res://tests/test_runner.tscn -- --case slice

echo "CI_OK"
