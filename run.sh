#!/usr/bin/env bash
# Bunker 13 - launcher
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
exec "$GODOT" --path "$DIR" "$@"
