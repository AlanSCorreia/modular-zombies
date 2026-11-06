"""Importa um GLB para um .blend editável.

Uso:
  blender -b --python source/blender/scripts/import_glb_to_blend.py -- \
      <entrada.glb> <saida.blend>
"""

import sys
from pathlib import Path

import bpy


def main() -> None:
    argv = sys.argv
    args = argv[argv.index("--") + 1 :] if "--" in argv else []
    if len(args) != 2:
        raise SystemExit(
            "uso: blender -b --python import_glb_to_blend.py -- <entrada.glb> <saida.blend>"
        )

    src = Path(args[0]).resolve()
    dst = Path(args[1]).resolve()
    if not src.exists():
        raise SystemExit(f"GLB não encontrado: {src}")

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(src))
    bpy.ops.file.pack_all()
    dst.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(dst), compress=True)
    print(f"BLEND_OK {dst}")


main()
