"""Gera a SKS autoral (coronha, receptor, cano, magazine e bolt).

Convenção: +Y no Blender vira -Z no jogo (frente), +Z vira +Y (cima).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_sks.py
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/weapons/sks/sks.blend"
GLB = ROOT / "assets/models/weapons/sks/sks.glb"


def material(name: str, color, metallic: float, roughness: float):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def box(name: str, parent, location: Vector, size: Vector, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = location
    obj.scale = size
    obj.data.materials.append(mat)
    return obj


def cylinder(name: str, parent, location: Vector, radius: float, depth: float, mat):
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth, vertices=12)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = location
    obj.rotation_euler.x = math.pi / 2.0
    obj.data.materials.append(mat)
    return obj


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    wood = material("SKSWood", (0.22, 0.12, 0.06), 0.0, 0.75)
    steel = material("SKSSteel", (0.16, 0.17, 0.18), 0.8, 0.35)

    root = bpy.data.objects.new("GunRoot", None)
    bpy.context.collection.objects.link(root)
    root.empty_display_type = "PLAIN_AXES"

    box("Stock", root, Vector((0, -0.28, 0.0)), Vector((0.065, 0.42, 0.11)), wood)
    box("Receiver", root, Vector((0, 0.0, 0.03)), Vector((0.07, 0.30, 0.11)), steel)
    box("Handguard", root, Vector((0, 0.24, 0.02)), Vector((0.055, 0.24, 0.07)), wood)
    cylinder("Barrel", root, Vector((0, 0.43, 0.04)), 0.014, 0.42, steel)
    box("Sight", root, Vector((0, 0.22, 0.10)), Vector((0.02, 0.04, 0.03)), steel)
    box("Magazine", root, Vector((0, 0.04, -0.075)), Vector((0.045, 0.08, 0.17)), steel)
    box("Trigger", root, Vector((0, -0.07, -0.06)), Vector((0.02, 0.045, 0.06)), steel)
    box("Bolt", root, Vector((0.045, 0.02, 0.07)), Vector((0.035, 0.16, 0.03)), steel)

    grip = bpy.data.objects.new("GripSocket", None)
    bpy.context.collection.objects.link(grip)
    grip.empty_display_type = "PLAIN_AXES"
    grip.parent = root
    grip.location = Vector((0, -0.14, -0.02))

    muzzle = bpy.data.objects.new("Muzzle", None)
    bpy.context.collection.objects.link(muzzle)
    muzzle.empty_display_type = "PLAIN_AXES"
    muzzle.parent = root
    muzzle.location = Vector((0, 0.64, 0.04))

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("SKS_ASSET_OK", GLB)


main()
