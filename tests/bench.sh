#!/usr/bin/env bash
# Mede FPS/frame/draw calls/memória do slice.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
cd "$DIR"
"$GODOT" --path . res://tests/test_runner.tscn -- --case bench
