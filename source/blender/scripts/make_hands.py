"""Gera o hands.glb compartilhado (mãos + antebraços + GripSocket).

Convenção Blender → glTF: +Y do Blender vira -Z do jogo (frente); +Z vira +Y.
Portanto dedos apontam para +Y e antebraço para -Y.

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_hands.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/hands/hands.blend"
GLB = ROOT / "assets/models/hands/hands.glb"


def material(name: str, color, roughness: float):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def empty(name: str, parent, location: Vector):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.parent = parent
    obj.location = location
    return obj


def box(name: str, parent, location: Vector, size: Vector, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
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
    obj.rotation_euler.x = 1.5707963  # eixo Y (frente/corpo)
    obj.data.materials.append(mat)
    return obj


def hand(name: str, parent, location: Vector, glove, sleeve) -> None:
    root = empty(name, parent, location)

    # Palma e dedos no eixo +Y (frente no jogo).
    box(name + "_Palm", root, Vector((0, 0.02, 0)), Vector((0.09, 0.11, 0.045)), glove)
    for i, x in enumerate((-0.033, -0.011, 0.011, 0.033)):
        box(
            "%s_Finger%d" % (name, i + 1),
            root,
            Vector((x, 0.115, 0.0)),
            Vector((0.018, 0.075, 0.028)),
            glove,
        )
    box(
        name + "_Thumb",
        root,
        Vector((0.058, 0.045, 0.005)),
        Vector((0.026, 0.065, 0.03)),
        glove,
    )
    cylinder(name + "_Forearm", root, Vector((0, -0.20, 0)), 0.045, 0.32, sleeve)


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    glove = material("HandsGlove", (0.075, 0.078, 0.085), 0.78)
    sleeve = material("HandsSleeve", (0.13, 0.15, 0.11), 0.9)

    grip = empty("GripSocket", None, Vector((0, 0, 0)))
    hand("HandR", grip, Vector((0, 0, 0)), glove, sleeve)
    # Apoio à frente do guarda-mão (game -Z => Blender +Y).
    hand("HandL", grip, Vector((0.035, 0.34, -0.03)), glove, sleeve)

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB")
    print("HANDS_OK", GLB)


main()
