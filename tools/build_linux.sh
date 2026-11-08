#!/usr/bin/env bash
# Gera o build Linux e roda um smoke headless.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-$HOME/.local/opt/godot/Godot_v4.7.2-stable_linux.x86_64}"
PRESET="${1:-Linux}"
OUT="$DIR/build/linux/bunker13.x86_64"
LOG="${TMPDIR:-/tmp}/bunker_build_linux.log"

mkdir -p "$DIR/build/linux"
rm -f "$OUT" "$DIR/build/linux/bunker13.pck" "$LOG"

"$GODOT" --headless --path "$DIR" --export-release "$PRESET" "$OUT" >"$LOG" 2>&1 || {
  cat "$LOG"
  echo "BUILD_FAIL export"
  exit 1
}

if [ ! -x "$OUT" ]; then
  cat "$LOG"
  echo "BUILD_FAIL binário ausente"
  exit 1
fi
if [ ! -f "$DIR/build/linux/bunker13.pck" ]; then
  cat "$LOG"
  echo "BUILD_FAIL pck ausente"
  exit 1
fi

"$OUT" --headless --quit-after 3 >"$LOG.smoke" 2>&1 || {
  cat "$LOG.smoke"
  echo "BUILD_FAIL smoke"
  exit 1
}
if grep -qE "SCRIPT ERROR|Failed to load" "$LOG.smoke"; then
  cat "$LOG.smoke"
  echo "BUILD_FAIL smoke_errors"
  exit 1
fi

echo "BUILD_OK bin=$(stat -c%s "$OUT") pck=$(stat -c%s "$DIR/build/linux/bunker13.pck")"
