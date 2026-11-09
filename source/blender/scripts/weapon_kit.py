"""Helpers compartilhados para modelar armas autorais no Blender.

Convenção do projeto (ver source/blender/README.md):
- metros reais;
- +Y no Blender = frente (-Z no Godot);
- +Z no Blender = cima (+Y no Godot);
- GunRoot, GripSocket e Muzzle são obrigatórios;
- partes móveis usam os nomes que o WeaponController procura
  (Slide, Magazine, Trigger).
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()


def reset() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(
    name: str,
    color,
    metallic: float = 0.0,
    roughness: float = 0.5,
    emission=None,
    emission_strength: float = 0.0,
):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
        if emission is not None:
            bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat


def root(name: str = "GunRoot"):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.empty_display_size = 0.04
    return obj


def empty(name: str, parent, location, rotation=(0.0, 0.0, 0.0), size: float = 0.02):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.empty_display_size = size
    obj.parent = parent
    obj.location = Vector(location)
    obj.rotation_euler = rotation
    return obj


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


def _smooth(obj, angle: float = 35.0) -> None:
    bpy.context.view_layer.objects.active = obj
    try:
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(angle))
    except (AttributeError, RuntimeError):
        bpy.ops.object.shade_smooth()


def box(
    name: str,
    parent,
    location,
    size,
    mat,
    rotation=(0.0, 0.0, 0.0),
    bevel: float = 0.002,
):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    _bevel(obj, bevel)
    return obj


def cylinder(
    name: str,
    parent,
    location,
    radius: float,
    depth: float,
    mat,
    axis: str = "Y",
    vertices: int = 20,
    rotation=(0.0, 0.0, 0.0),
    smooth: bool = True,
):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices, radius=radius, depth=depth, location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    # O cilindro nasce no eixo Z; rotaciona para o eixo pedido.
    if axis == "Y":
        obj.rotation_euler.x += math.pi / 2.0
    elif axis == "X":
        obj.rotation_euler.y += math.pi / 2.0
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    obj.data.materials.append(mat)
    if smooth:
        _smooth(obj)
    return obj


def torus(
    name: str,
    parent,
    location,
    major_radius: float,
    minor_radius: float,
    mat,
    axis: str = "Y",
    rotation=(0.0, 0.0, 0.0),
):
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major_radius, minor_radius=minor_radius,
        major_segments=24, minor_segments=8, location=location,
        rotation=rotation,
    )
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    if axis == "Y":
        obj.rotation_euler.x += math.pi / 2.0
    elif axis == "X":
        obj.rotation_euler.y += math.pi / 2.0
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    obj.data.materials.append(mat)
    _smooth(obj)
    return obj


def sphere(name: str, parent, location, radius: float, mat, scale=(1.0, 1.0, 1.0)):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=20, ring_count=10, radius=radius, location=location,
    )
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    _smooth(obj, 60.0)
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
    )
    print("WEAPON_ASSET_OK", glb, *extras)
