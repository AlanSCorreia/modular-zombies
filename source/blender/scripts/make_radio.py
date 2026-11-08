"""Gera o rádio autoral (corpo, antena, dial e luz).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_radio.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/props/radio/radio.blend"
GLB = ROOT / "assets/models/props/radio/radio.glb"


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
    body = material("RadioBody", (0.12, 0.16, 0.12), 0.2, 0.65)
    metal = material("RadioMetal", (0.35, 0.36, 0.34), 0.8, 0.35)
    dial = material("RadioDial", (0.95, 0.55, 0.12), 0.1, 0.4)

    box("RadioBody", Vector((0, 0, 0.12)), Vector((0.32, 0.18, 0.24)), body)
    box("RadioDial", Vector((0.10, -0.095, 0.16)), Vector((0.08, 0.01, 0.06)), dial)
    box("RadioGrill", Vector((-0.06, -0.095, 0.12)), Vector((0.12, 0.01, 0.10)), metal)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.006, depth=0.34, vertices=8)
    antenna = bpy.context.object
    antenna.name = "RadioAntenna"
    antenna.location = Vector((-0.11, 0.0, 0.40))
    antenna.rotation_euler.y = 0.25
    antenna.data.materials.append(metal)

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("RADIO_ASSET_OK", GLB)


main()
