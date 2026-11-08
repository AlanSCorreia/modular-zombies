"""Normaliza a pistol existente para metros, orienta a frente e adiciona sockets.

Uso (na raiz do projeto):
  blender -b source/blender/weapons/pistol/pistol.blend \
      --python source/blender/scripts/normalize_pistol.py
"""

import math
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/weapons/pistol/pistol.blend"
GLB = ROOT / "assets/models/weapons/pistol/pistol.glb"


def bbox(obj):
    verts = [obj.matrix_world @ v.co for v in obj.data.vertices]
    xs = [v.x for v in verts]
    ys = [v.y for v in verts]
    zs = [v.z for v in verts]
    return min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)


def main() -> None:
    obj = bpy.data.objects.get("Gun")
    if obj is None:
        raise SystemExit("mesh Gun não encontrada")

    # Escala de mm para metros + frente +Y (glTF -Z).
    obj.data.transform(Matrix.Scale(0.001, 4))
    obj.data.transform(Matrix.Rotation(math.pi / 2.0, 4, "Z"))
    obj.data.transform(obj.matrix_world.inverted())
    obj.matrix_world = Matrix.Identity(4)

    min_x, max_x, min_y, max_y, min_z, max_z = bbox(obj)
    obj.data.transform(Matrix.Translation(Vector((
        -(min_x + max_x) * 0.5,
        -(min_y + max_y) * 0.5,
        -min_z,
    ))))

    for name in ("GripSocket", "Muzzle"):
        old = bpy.data.objects.get(name)
        if old is not None:
            bpy.data.objects.remove(old, do_unlink=True)

    min_x, max_x, min_y, max_y, min_z, max_z = bbox(obj)
    height = max_z - min_z
    root = bpy.data.objects.get("GunRoot")
    if root is None:
        root = bpy.data.objects.new("GunRoot", None)
        bpy.context.collection.objects.link(root)
        root.empty_display_type = "PLAIN_AXES"

    grip = bpy.data.objects.new("GripSocket", None)
    bpy.context.collection.objects.link(grip)
    grip.empty_display_type = "PLAIN_AXES"
    grip.parent = root
    grip.location = Vector((0.0, min_y + 0.035, min_z + 0.035))

    muzzle = bpy.data.objects.new("Muzzle", None)
    bpy.context.collection.objects.link(muzzle)
    muzzle.empty_display_type = "PLAIN_AXES"
    muzzle.parent = root
    muzzle.location = Vector((0.0, max_y, min_z + height * 0.72))

    obj.parent = root
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("PISTOL_NORMALIZED", GLB)


main()
