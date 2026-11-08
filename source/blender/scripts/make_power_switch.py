"""Gera o interruptor de energia autoral (painel + alavanca).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_power_switch.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/props/power_switch/power_switch.blend"
GLB = ROOT / "assets/models/props/power_switch/power_switch.glb"


def material(name: str, color, metallic: float, roughness: float):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def box(name: str, location: Vector, size: Vector, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    obj = bpy.context.object
    obj.name = name
    obj.location = location
    obj.scale = size
    obj.data.materials.append(mat)
    return obj


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    panel = material("PowerPanel", (0.16, 0.17, 0.16), 0.6, 0.45)
    lever = material("PowerLever", (0.85, 0.55, 0.12), 0.3, 0.4)
    lamp = material("PowerLamp", (0.2, 0.9, 0.35), 0.1, 0.3)

    box("PowerPanel", Vector((0, 0, 0)), Vector((0.34, 0.08, 0.46)), panel)
    box("PowerLever", Vector((0, -0.06, 0.02)), Vector((0.10, 0.06, 0.18)), lever)
    box("PowerLamp", Vector((0.10, -0.05, 0.16)), Vector((0.05, 0.03, 0.05)), lamp)

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("POWER_ASSET_OK", GLB)


main()
