"""Gera a faca autoral (lâmina + cabo + GripSocket).

Convenção: Blender +Y vira -Z no jogo (frente), então a lâmina aponta +Y.

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_knife.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/weapons/knife/knife.blend"
GLB = ROOT / "assets/models/weapons/knife/knife.glb"


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
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = location
    obj.scale = size
    obj.data.materials.append(mat)
    return obj


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    steel = material("KnifeSteel", (0.58, 0.61, 0.64), 0.9, 0.25)
    grip_mat = material("KnifeGrip", (0.045, 0.05, 0.045), 0.1, 0.85)

    root = bpy.data.objects.new("GripSocket", None)
    bpy.context.collection.objects.link(root)
    root.empty_display_type = "PLAIN_AXES"

    # Cabo no eixo Y (atrás da mão), guarda e lâmina à frente (+Y).
    box("Handle", root, Vector((0, -0.015, 0)), Vector((0.032, 0.13, 0.04)), grip_mat)
    box("Guard", root, Vector((0, 0.065, 0.0)), Vector((0.10, 0.022, 0.032)), steel)
    box("Blade", root, Vector((0, 0.20, 0.01)), Vector((0.012, 0.27, 0.052)), steel)
    box("Tip", root, Vector((0, 0.355, 0.01)), Vector((0.010, 0.06, 0.028)), steel)

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("KNIFE_OK", GLB)


main()
