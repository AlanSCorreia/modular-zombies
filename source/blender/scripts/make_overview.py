"""Monta uma cena de visualização com os modelos do jogo.

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_overview.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()

MODELS = [
    ("glock17", "assets/models/weapons/glock17/glock17.glb"),
    ("mp5", "assets/models/weapons/mp5/mp5.glb"),
    ("m870", "assets/models/weapons/m870/m870.glb"),
    ("ak74", "assets/models/weapons/ak74/ak74.glb"),
    ("wunder", "assets/models/weapons/wunder/wunder.glb"),
    ("pistol", "assets/models/weapons/pistol/pistol.glb"),
    ("zombie", "assets/models/enemies/zombie/zombie.glb"),
]


def bounds(objects):
    mins = Vector((1e9, 1e9, 1e9))
    maxs = Vector((-1e9, -1e9, -1e9))
    found = False
    for obj in objects:
        if obj.type != "MESH":
            continue
        found = True
        for corner in obj.bound_box:
            p = obj.matrix_world @ Vector(corner)
            mins = Vector((min(mins.x, p.x), min(mins.y, p.y), min(mins.z, p.z)))
            maxs = Vector((max(maxs.x, p.x), max(maxs.y, p.y), max(maxs.z, p.z)))
    if not found:
        return Vector((0, 0, 0)), Vector((0, 0, 0))
    return mins, maxs


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    spacing = 2.2

    for i, (name, rel) in enumerate(MODELS):
        before = set(bpy.data.objects)
        bpy.ops.import_scene.gltf(filepath=str(ROOT / rel))
        new = [o for o in bpy.data.objects if o not in before]

        mins, maxs = bounds(new)
        center = (mins + maxs) * 0.5
        target = Vector(((i % 3) * spacing - spacing, -(i // 3) * spacing, 0.0))
        delta = target - center
        for obj in new:
            if obj.parent is None:
                obj.location += delta

        mins, maxs = bounds(new)
        bpy.ops.object.text_add(
            location=(target.x, target.y, maxs.z + 0.18)
        )
        label = bpy.context.object
        label.data.body = name
        label.data.align_x = "CENTER"
        label.data.align_y = "CENTER"
        label.data.size = 0.14

    bpy.ops.wm.save_as_mainfile(
        filepath=str(ROOT / "source/blender/overview.blend"), compress=True
    )
    print("OVERVIEW_OK")


main()
