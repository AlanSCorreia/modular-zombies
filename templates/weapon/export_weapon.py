"""Template de exportação de arma (Blender 4.5, headless ou UI).

Uso:
  WEAPON_ID=glock17 blender --background --python export_weapon.py

Pré-requisitos no .blend:
- raiz chamada WEAPON_ID (Empty)
- arma sem mãos
- empties GripSocket, Muzzle e EjectPort
- escala em metros, frente -Z, cima +Y
"""
import bpy
import os
from pathlib import Path

WEAPON_ID = os.environ.get("WEAPON_ID", "example")
OUT_DIR = Path("assets/models/weapons") / WEAPON_ID
OUT_DIR.mkdir(parents=True, exist_ok=True)
OUT_FILE = OUT_DIR / f"{WEAPON_ID}.glb"

# Seleciona a raiz da arma e seus filhos (não inclui mãos)
root = bpy.data.objects.get(WEAPON_ID)
if root is None:
    raise RuntimeError(f"Raiz '{WEAPON_ID}' não encontrada")

bpy.ops.object.select_all(action='DESELECT')
root.select_set(True)
for o in root.children_recursive:
    o.select_set(True)
bpy.context.view_layer.objects.active = root

bpy.ops.export_scene.gltf(
    filepath=str(OUT_FILE),
    export_format='GLB',
    use_selection=True,
    export_apply=True,
    export_animations=False,
    export_yup=True,
)
print("WEAPON_EXPORT_OK", OUT_FILE)
