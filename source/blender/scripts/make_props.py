"""Gera props simples autorais: barril e granada.

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_props.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()


def material(name: str, color, metallic=0.0, roughness=0.6):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def export(blend_path: str, glb_path: str) -> None:
    dst = ROOT / blend_path
    dst.parent.mkdir(parents=True, exist_ok=True)
    glb = ROOT / glb_path
    glb.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(dst), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(glb), export_format="GLB")
    print("PROP_OK", glb_path)


def make_barrel() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=1.1, location=(0, 0, 0))
    barrel = bpy.context.object
    barrel.name = "Barrel"
    barrel.data.materials.append(material("BarrelRed", (0.55, 0.08, 0.05), 0.35, 0.5))

    for z in (-0.42, 0.42):
        bpy.ops.mesh.primitive_torus_add(
            major_radius=0.405, minor_radius=0.035, location=(0, 0, z)
        )
        ring = bpy.context.object
        ring.name = "Ring"
        ring.data.materials.append(material("BarrelMetal", (0.12, 0.12, 0.12), 0.8, 0.35))

    export("source/blender/props/barrel/barrel.blend", "assets/models/props/barrel/barrel.glb")


def make_grenade() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, segments=16, ring_count=12)
    body = bpy.context.object
    body.name = "Grenade"
    body.data.materials.append(material("GrenadeGreen", (0.18, 0.24, 0.12), 0.2, 0.55))

    bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.09, location=(0, 0, 0.14))
    fuse = bpy.context.object
    fuse.name = "Fuse"
    fuse.data.materials.append(material("GrenadeFuse", (0.55, 0.42, 0.16), 0.1, 0.7))

    export("source/blender/props/grenade/grenade.blend", "assets/models/props/grenade/grenade.glb")


make_barrel()
make_grenade()
