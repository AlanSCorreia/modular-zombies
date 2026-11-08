"""Prepara as armas para as mãos compartilhadas.

- Remove as mãos embutidas da Glock (regra: um único hands.glb).
- Adiciona `GripSocket` e `Muzzle` em Glock e MP5 para o ViewmodelFactory.
- Reexporta os GLBs.

Uso (na raiz do projeto):
  blender -b source/blender/weapons/glock17/glock17.blend \
      --python source/blender/scripts/prepare_weapon_hands.py -- glock17
"""

import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()


def add_empty(name: str, parent, location: Vector):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.parent = parent
    obj.location = location
    return obj


def glock(path: Path) -> None:
    for name in ("HandL", "HandR"):
        obj = bpy.data.objects.get(name)
        if obj is not None:
            bpy.data.objects.remove(obj, do_unlink=True)
    root = bpy.data.objects.get("GunRoot")
    if bpy.data.objects.get("GripSocket") is None:
        add_empty("GripSocket", root, Vector((0.0, -0.055, -0.02)))
    if bpy.data.objects.get("Muzzle") is None:
        add_empty("Muzzle", root, Vector((0.0, 0.12, 0.108)))
    bpy.ops.wm.save_as_mainfile(filepath=str(path), compress=True)
    bpy.ops.export_scene.gltf(
        filepath=str(ROOT / "assets/models/weapons/glock17/glock17.glb"),
        export_format="GLB",
    )
    print("WEAPON_OK glock17")


def mp5(path: Path) -> None:
    root = bpy.data.objects.get("RootNode")
    if bpy.data.objects.get("GripSocket") is None:
        add_empty("GripSocket", root, Vector((0.0, -0.02, -0.06)))
    if bpy.data.objects.get("Muzzle") is None:
        add_empty("Muzzle", root, Vector((0.0, 0.223, 0.014)))
    bpy.ops.wm.save_as_mainfile(filepath=str(path), compress=True)
    bpy.ops.export_scene.gltf(
        filepath=str(ROOT / "assets/models/weapons/mp5/mp5.glb"),
        export_format="GLB",
    )
    print("WEAPON_OK mp5")


def main() -> None:
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    which = args[0] if args else "glock17"
    if which == "glock17":
        glock(ROOT / "source/blender/weapons/glock17/glock17.blend")
    elif which == "mp5":
        mp5(ROOT / "source/blender/weapons/mp5/mp5.blend")
    else:
        print("WEAPON_SKIP", which)


main()
