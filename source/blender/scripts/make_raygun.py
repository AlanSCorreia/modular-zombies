"""Gera a wonder weapon Ray Gun autoral.

Convenção: +Y no Blender vira -Z no jogo (frente), +Z vira +Y (cima).
Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_raygun.py
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/weapons/raygun/raygun.blend"
GLB = ROOT / "assets/models/weapons/raygun/raygun.glb"


def material(name: str, color, metallic: float, roughness: float,
             emission=None):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
        if emission is not None:
            bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
            bsdf.inputs["Emission Strength"].default_value = 3.0
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


def cylinder(name: str, parent, location: Vector, radius: float, depth: float,
             mat, rotation: Vector = Vector((0, 0, 0))):
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=depth, vertices=12)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = location
    obj.rotation_euler = rotation
    obj.data.materials.append(mat)
    return obj


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    body = material("RayBody", (0.10, 0.12, 0.14), 0.7, 0.35)
    metal = material("RayMetal", (0.35, 0.40, 0.42), 0.9, 0.25)
    glow = material("RayGlow", (0.12, 0.9, 0.35), 0.1, 0.2,
                    emission=(0.1, 1.0, 0.3))

    root = bpy.data.objects.new("GunRoot", None)
    bpy.context.collection.objects.link(root)
    root.empty_display_type = "PLAIN_AXES"

    box("Body", root, Vector((0, 0, 0.02)), Vector((0.10, 0.30, 0.10)), body)
    cylinder("Barrel", root, Vector((0, 0.22, 0.04)), 0.026, 0.32, metal,
             Vector((math.pi / 2.0, 0, 0)))
    for i, y in enumerate((0.10, 0.16, 0.22)):
        bpy.ops.mesh.primitive_torus_add(
            major_radius=0.060, minor_radius=0.008,
            location=(0, y, 0.04), rotation=(math.pi / 2.0, 0, 0)
        )
        ring = bpy.context.object
        ring.name = "Coil%d" % (i + 1)
        ring.parent = root
        ring.data.materials.append(glow)
    box("Grip", root, Vector((0, -0.09, -0.09)), Vector((0.07, 0.09, 0.18)), body)
    box("Trigger", root, Vector((0, -0.01, -0.08)), Vector((0.02, 0.04, 0.05)), metal)

    grip = bpy.data.objects.new("GripSocket", None)
    bpy.context.collection.objects.link(grip)
    grip.empty_display_type = "PLAIN_AXES"
    grip.parent = root
    grip.location = Vector((0, -0.10, -0.02))

    muzzle = bpy.data.objects.new("Muzzle", None)
    bpy.context.collection.objects.link(muzzle)
    muzzle.empty_display_type = "PLAIN_AXES"
    muzzle.parent = root
    muzzle.location = Vector((0, 0.38, 0.04))

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("RAYGUN_ASSET_OK", GLB)


main()
