#!/usr/bin/env bash
# Abre o Blender com a cena de visão geral dos modelos (ou um arquivo passado).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLENDER="${BLENDER_BIN:-$HOME/.local/bin/blender}"

if [ ! -x "$BLENDER" ]; then
  echo "Blender não encontrado em $BLENDER. Defina BLENDER_BIN." >&2
  exit 1
fi

if [ "$#" -eq 0 ]; then
  set -- "$DIR/source/blender/overview.blend"
fi

exec "$BLENDER" "$@"
