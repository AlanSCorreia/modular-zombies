"""Gera a trap de proximidade autoral (mina + luz).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_trap.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/props/trap/trap.blend"
GLB = ROOT / "assets/models/props/trap/trap.glb"


def material(name: str, color, metallic: float, roughness: float):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    steel = material("TrapSteel", (0.18, 0.19, 0.18), 0.7, 0.45)
    red = material("TrapLight", (0.8, 0.06, 0.03), 0.2, 0.4)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.20, depth=0.08, vertices=16)
    base = bpy.context.object
    base.name = "TrapBase"
    base.location = Vector((0, 0, 0.04))
    base.data.materials.append(steel)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.045, vertices=12)
    top = bpy.context.object
    top.name = "TrapTop"
    top.location = Vector((0, 0, 0.10))
    top.data.materials.append(steel)

    bpy.ops.mesh.primitive_cube_add(size=1.0)
    light = bpy.context.object
    light.name = "TrapLight"
    light.location = Vector((0, 0, 0.14))
    light.scale = Vector((0.05, 0.05, 0.025))
    light.data.materials.append(red)

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("TRAP_ASSET_OK", GLB)


main()
