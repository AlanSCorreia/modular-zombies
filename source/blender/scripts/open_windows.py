"""Abre os vãos de janela do Bunker 13 no perímetro.

Substitui as quatro paredes externas por segmentos retangulares, deixando
vãos de 2,2 m nos centros das barricadas. O GLB exportado mantém um mesh por
segmento para que o `MapSceneBuilder` gere colisão por AABB sem tapar os vãos.

Uso (na raiz do projeto):
  blender -b source/blender/maps/bunker13/bunker13.blend \
      --python source/blender/scripts/open_windows.py
"""

from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path.cwd()
BLEND = ROOT / "source/blender/maps/bunker13/bunker13.blend"
GLB = ROOT / "assets/models/maps/bunker13/bunker13.glb"

WINDOW_W = 2.2
SILL_H = 0.9
TOP_Y = 2.5
HEIGHT = 3.4
THICK = 0.3


def _cube(name: str, center: Vector, size: Vector, material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if material is not None:
        obj.data.materials.append(material)
    return obj


def _segments(wall_name: str, axis: str, fixed: float, lo: float, hi: float,
              centers: list[float], material) -> None:
    obj = bpy.data.objects.get(wall_name)
    if obj is None:
        print("SKIP missing", wall_name)
        return
    bpy.data.objects.remove(obj, do_unlink=True)

    spans: list[tuple[float, float]] = []
    cursor = lo
    for c in sorted(centers):
        start = c - WINDOW_W * 0.5
        end = c + WINDOW_W * 0.5
        if start > cursor:
            spans.append((cursor, start))
        spans.append((start, end))
        cursor = end
    if cursor < hi:
        spans.append((cursor, hi))

    idx = 0
    for start, end in spans:
        mid = (start + end) * 0.5
        length = end - start
        is_window = any(abs(mid - c) < 0.01 for c in centers)
        if is_window:
            # Peitoril e verga deixam o vão livre entre SILL_H e TOP_Y.
            pieces = [
                ((mid, fixed, SILL_H * 0.5), (length, THICK, SILL_H)),
                ((mid, fixed, (TOP_Y + HEIGHT) * 0.5),
                 (length, THICK, HEIGHT - TOP_Y)),
            ]
        else:
            pieces = [((mid, fixed, HEIGHT * 0.5), (length, THICK, HEIGHT))]
        for center, size in pieces:
            if axis == "y":
                center = (fixed, center[0], center[2])
                size = (THICK, size[0], size[2])
            _cube("%s_%d" % (wall_name, idx), Vector(center), Vector(size), material)
            idx += 1
    print("WALL_OK", wall_name, "pieces", idx)


def main() -> None:
    # Parede norte (game z=17): bar_A1/A2/A3.
    _segments("Wall_N", "x", -17.0, -9.0, 24.0, [-5.5, 0.0, 5.5],
              bpy.data.materials.get("Material_2"))
    # Parede sul (game z=-8): bar_C1/C2.
    _segments("Wall_S", "x", 8.0, -9.0, 24.0, [12.5, 20.0],
              bpy.data.materials.get("Material_3"))
    # Parede oeste (game x=-9): bar_B1/B2 (game z -5 e 1 => y 5 e -1).
    _segments("Wall_W", "y", -9.0, -17.0, 8.0, [5.0, -1.0],
              bpy.data.materials.get("Material_2"))
    # Parede leste (game x=24): bar_D1/D2 (game z 8 e 14 => y -8 e -14).
    _segments("Wall_E", "y", 24.0, -17.0, 8.0, [-8.0, -14.0],
              bpy.data.materials.get("Material_2"))

    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB",
                              export_lights=True)
    print("WINDOWS_OK", GLB)


main()
