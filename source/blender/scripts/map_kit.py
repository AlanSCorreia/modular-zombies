"""Helpers para mapas autorais no Blender.

Convenção: metros; Godot X/Z no plano horizontal e Y para cima.
No Blender, o ponto Godot (x, y, z) vira (x, -z, y).
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()


def reset() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name: str, color, roughness: float = 0.65, metallic: float = 0.0,
             emission=None, emission_strength: float = 0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
        if emission is not None:
            bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def gpos(x: float, y: float, z: float) -> Vector:
    return Vector((x, -z, y))


def _bevel(obj, width: float) -> None:
    if width <= 0.0:
        return
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new("Bevel", "BEVEL")
    mod.width = width
    mod.segments = 2
    mod.limit_method = "ANGLE"
    mod.angle_limit = math.radians(40.0)
    bpy.ops.object.modifier_apply(modifier=mod.name)


def root(name: str = "MapRoot"):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.empty_display_size = 0.5
    return obj


def empty(name: str, parent, x: float = 0.0, y: float = 0.0, z: float = 0.0,
          rot_y: float = 0.0):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.empty_display_size = 0.25
    obj.parent = parent
    obj.location = gpos(x, y, z)
    obj.rotation_euler.z = rot_y
    return obj


def box(name: str, parent, x: float, y: float, z: float,
        sx: float, sy: float, sz: float, mat, rot_y: float = 0.0,
        bevel: float = 0.01):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=gpos(x, y, z),
                                    rotation=(0.0, 0.0, rot_y))
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.scale = (sx, sz, sy)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    _bevel(obj, bevel)
    return obj


def cylinder(name: str, parent, x: float, y: float, z: float,
             radius: float, depth: float, mat, vertices: int = 16,
             bevel: float = 0.0):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices, radius=radius, depth=depth, location=gpos(x, y, z),
        rotation=(0.0, 0.0, 0.0),
    )
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    obj.data.materials.append(mat)
    _bevel(obj, bevel)
    return obj


def sphere(name: str, parent, x: float, y: float, z: float, radius: float,
           mat, scale=(1.0, 1.0, 1.0)):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=16, ring_count=8, radius=radius, location=gpos(x, y, z),
    )
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.scale = (scale[0], scale[2], scale[1])
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    return obj


def floor(name: str, parent, x1: float, z1: float, x2: float, z2: float,
          y: float, mat, thickness: float = 0.2):
    w = abs(x2 - x1)
    d = abs(z2 - z1)
    return box(name, parent, (x1 + x2) * 0.5, y - thickness * 0.5,
               (z1 + z2) * 0.5, w, thickness, d, mat, bevel=0.0)


def ceiling(name: str, parent, x1: float, z1: float, x2: float, z2: float,
            y: float, mat, thickness: float = 0.2):
    w = abs(x2 - x1)
    d = abs(z2 - z1)
    return box(name, parent, (x1 + x2) * 0.5, y + thickness * 0.5,
               (z1 + z2) * 0.5, w, thickness, d, mat, bevel=0.0)


def wall_x(name: str, parent, x1: float, x2: float, z: float, y: float,
           height: float, thickness: float, mat, openings=()):
    """Parede ao longo de X. openings = [(xa, xb, bottom, top), ...]."""
    ops = sorted(openings, key=lambda o: o[0])
    cursor = x1
    idx = 0
    for a, b, bottom, top in ops:
        if a > cursor:
            box("%s_%d" % (name, idx), parent, (cursor + a) * 0.5,
                y + height * 0.5, z, a - cursor, height, thickness, mat,
                bevel=0.0)
            idx += 1
        if bottom > 0.01:
            box("%s_sill_%d" % (name, idx), parent, (a + b) * 0.5,
                y + bottom * 0.5, z, b - a, bottom, thickness, mat,
                bevel=0.0)
            idx += 1
        if top < height - 0.01:
            box("%s_lintel_%d" % (name, idx), parent, (a + b) * 0.5,
                y + (top + height) * 0.5, z, b - a, height - top,
                thickness, mat, bevel=0.0)
            idx += 1
        cursor = max(cursor, b)
    if cursor < x2 - 0.01:
        box("%s_%d" % (name, idx), parent, (cursor + x2) * 0.5,
            y + height * 0.5, z, x2 - cursor, height, thickness, mat,
            bevel=0.0)


def wall_z(name: str, parent, z1: float, z2: float, x: float, y: float,
           height: float, thickness: float, mat, openings=()):
    """Parede ao longo de Z. openings = [(za, zb, bottom, top), ...]."""
    ops = sorted(openings, key=lambda o: o[0])
    cursor = z1
    idx = 0
    for a, b, bottom, top in ops:
        if a > cursor:
            box("%s_%d" % (name, idx), parent, x, y + height * 0.5,
                (cursor + a) * 0.5, thickness, height, a - cursor, mat,
                bevel=0.0)
            idx += 1
        if bottom > 0.01:
            box("%s_sill_%d" % (name, idx), parent, x,
                y + bottom * 0.5, (a + b) * 0.5, thickness, bottom,
                b - a, mat, bevel=0.0)
            idx += 1
        if top < height - 0.01:
            box("%s_lintel_%d" % (name, idx), parent, x,
                y + (top + height) * 0.5, (a + b) * 0.5, thickness,
                height - top, b - a, mat, bevel=0.0)
            idx += 1
        cursor = max(cursor, b)
    if cursor < z2 - 0.01:
        box("%s_%d" % (name, idx), parent, x, y + height * 0.5,
            (cursor + z2) * 0.5, thickness, height, z2 - cursor, mat,
            bevel=0.0)


def door(name: str, parent, x: float, z: float, y: float, width: float,
         height: float, axis: str, frame_mat, slab_mat, open_slab=False):
    """Cria moldura e, se fechada, a folha Door_<id>."""
    if axis == "x":
        post = (0.16, height, 0.34)
        box(name + "_PostL", parent, x - width * 0.5, y + height * 0.5, z,
            post[0], post[1], post[2], frame_mat, bevel=0.0)
        box(name + "_PostR", parent, x + width * 0.5, y + height * 0.5, z,
            post[0], post[1], post[2], frame_mat, bevel=0.0)
        box(name + "_Lintel", parent, x, y + height + 0.1, z,
            width + 0.32, 0.2, 0.34, frame_mat, bevel=0.0)
        if not open_slab:
            box("Door_" + name, parent, x, y + height * 0.5, z,
                width, height, 0.12, slab_mat, bevel=0.0)
    else:
        post = (0.34, height, 0.16)
        box(name + "_PostL", parent, x, y + height * 0.5,
            z - width * 0.5, post[0], post[1], post[2], frame_mat,
            bevel=0.0)
        box(name + "_PostR", parent, x, y + height * 0.5,
            z + width * 0.5, post[0], post[1], post[2], frame_mat,
            bevel=0.0)
        box(name + "_Lintel", parent, x, y + height + 0.1, z,
            0.34, 0.2, width + 0.32, frame_mat, bevel=0.0)
        if not open_slab:
            box("Door_" + name, parent, x, y + height * 0.5, z,
                0.12, height, width, slab_mat, bevel=0.0)


def barricade(name: str, parent, x: float, z: float, rot_y: float,
              wood_mat, frame_mat):
    holder = empty("Barricade_" + name, parent, x, 0.0, z, rot_y)
    box(name + "_FrameL", holder, -1.1, 1.4, 0.0, 0.12, 2.2, 0.16,
        frame_mat, bevel=0.0)
    box(name + "_FrameR", holder, 1.1, 1.4, 0.0, 0.12, 2.2, 0.16,
        frame_mat, bevel=0.0)
    for i in range(6):
        box("Plank_%d" % i, holder, 0.0, 0.85 + i * 0.24, 0.0,
            2.1, 0.18, 0.1, wood_mat, rot_y=0.0, bevel=0.0)
    return holder


def wallbuy(name: str, parent, x: float, z: float, rot_y: float,
            plaque_mat, frame_mat):
    holder = empty("WallBuy_" + name, parent, x, 1.45, z, rot_y)
    box("BuyPlaque", holder, 0.0, 0.0, 0.06, 1.0, 0.55, 0.08,
        plaque_mat, bevel=0.0)
    box("BuyFrame", holder, 0.0, 0.0, 0.0, 1.14, 0.69, 0.05,
        frame_mat, bevel=0.0)
    return holder


def perk_machine(perk_id: str, parent, x: float, z: float, rot_y: float,
                 body_mat, accent_mat):
    holder = empty("Perk_" + perk_id, parent, x, 0.0, z, rot_y)
    box("PerkBody", holder, 0.0, 0.9, 0.0, 0.95, 1.8, 0.7,
        body_mat, bevel=0.02)
    box("PerkPanel", holder, 0.0, 1.05, 0.37, 0.72, 0.95, 0.05,
        accent_mat, bevel=0.0)
    box("PerkTop", holder, 0.0, 1.86, 0.0, 1.0, 0.12, 0.75,
        accent_mat, bevel=0.0)
    return holder


def mystery_box(parent, x: float, z: float, rot_y: float, body_mat,
                trim_mat, glow_mat):
    holder = empty("Box", parent, x, 0.0, z, rot_y)
    box("BoxBody", holder, 0.0, 0.45, 0.0, 1.45, 0.9, 0.95,
        body_mat, bevel=0.02)
    box("Lid", holder, 0.0, 0.95, 0.0, 1.5, 0.12, 1.0,
        body_mat, bevel=0.01)
    box("BoxTrim", holder, 0.0, 0.96, 0.0, 1.52, 0.04, 1.02,
        trim_mat, bevel=0.0)
    box("BoxGlow", holder, 0.0, 0.45, 0.49, 0.9, 0.1, 0.02,
        glow_mat, bevel=0.0)
    return holder


def lamp(name: str, parent, x: float, y: float, z: float, color,
         energy: float = 250.0, distance: float = 8.0):
    data = bpy.data.lights.new(name, "POINT")
    data.color = color
    data.energy = energy
    data.shadow_soft_size = 0.35
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj.location = gpos(x, y, z)
    obj.data.use_custom_distance = True
    obj.data.cutoff_distance = distance
    return obj


def export(blend, glb, extras=()) -> None:
    blend = Path(blend)
    glb = Path(glb)
    blend.parent.mkdir(parents=True, exist_ok=True)
    glb.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(blend), compress=True)
    bpy.ops.export_scene.gltf(
        filepath=str(glb),
        export_format="GLB",
        export_apply=True,
        export_lights=True,
    )
    print("MAP_ASSET_OK", glb, *extras)
