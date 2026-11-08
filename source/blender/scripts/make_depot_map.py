"""Gera o mapa Depot (2 salas) para a Etapa 7.

Convenção: Blender (x,y,z) -> glTF/jogo (x,z,-y).
Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_depot_map.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/maps/depot/depot.blend"
GLB = ROOT / "assets/models/maps/depot/depot.glb"


def material(name: str, color, metallic=0.0, roughness=0.7):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
        bsdf.inputs["Metallic"].default_value = metallic
        bsdf.inputs["Roughness"].default_value = roughness
    return mat


def box(name: str, game_pos: Vector, game_size: Vector, mat):
    # game_pos/size em metros do jogo; converte para Blender.
    loc = Vector((game_pos.x, -game_pos.z, game_pos.y))
    size = Vector((game_size.x, game_size.z, game_size.y))
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    obj = bpy.context.object
    obj.name = name
    obj.location = loc
    obj.scale = size
    obj.data.materials.append(mat)
    return obj


def empty(name: str, game_pos: Vector):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.empty_display_type = "PLAIN_AXES"
    obj.location = Vector((game_pos.x, -game_pos.z, game_pos.y))
    return obj


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    concrete = material("DepotConcrete", (0.24, 0.25, 0.23), 0.0, 0.85)
    metal = material("DepotMetal", (0.18, 0.19, 0.18), 0.75, 0.4)
    wood = material("DepotWood", (0.28, 0.18, 0.10), 0.0, 0.8)

    # Piso/teto das duas salas (x -8..24, z -6..6).
    box("Floor", Vector((8, -0.15, 0)), Vector((32, 0.3, 12)), concrete)
    box("Ceiling", Vector((8, 3.55, 0)), Vector((32, 0.3, 12)), concrete)

    # Perímetro.
    box("Wall_N", Vector((8, 1.7, 6)), Vector((32.3, 3.4, 0.3)), concrete)
    box("Wall_S", Vector((8, 1.7, -6)), Vector((32.3, 3.4, 0.3)), concrete)
    box("Wall_W", Vector((-8, 1.7, 0)), Vector((0.3, 3.4, 12.3)), concrete)
    box("Wall_E", Vector((24, 1.7, 0)), Vector((0.3, 3.4, 12.3)), concrete)

    # Parede central em x=8 com vão de porta em z=0.
    box("Wall_Mid_A", Vector((8, 1.7, 3.65)), Vector((0.3, 3.4, 4.7)), concrete)
    box("Wall_Mid_B", Vector((8, 1.7, -3.65)), Vector((0.3, 3.4, 4.7)), concrete)
    box("Lintel", Vector((8, 2.95, 0)), Vector((0.3, 0.9, 2.6)), concrete)

    # Porta e rack de wallbuy (o runtime usa esses nomes).
    box("Door_door1", Vector((8, 1.25, 0)), Vector((0.2, 2.5, 2.6)), metal)
    holder = empty("WallBuy_wb_depot", Vector((-7.65, 1.45, 0)))
    rack = box("BuyRack", Vector((-7.65, 1.45, 0)), Vector((0.12, 0.8, 0.5)), wood)
    rack.parent = holder
    rack.location = Vector((0, 0, 0))

    # Iluminação autoral de teto.
    bpy.ops.object.light_add(type="POINT")
    light = bpy.context.object
    light.name = "DepotLight"
    light.location = Vector((8, 0, 2.8))
    light.data.energy = 900
    light.data.color = (1.0, 0.82, 0.6)
    light.data.shadow_soft_size = 2.0

    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB",
                              export_lights=True)
    print("DEPOT_MAP_OK", GLB)


main()
