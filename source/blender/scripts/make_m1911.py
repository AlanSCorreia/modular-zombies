"""Gera a M1911 autoral (frame, slide, cano, grip, magazine e mira).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_m1911.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import weapon_kit as kit

BLEND = "source/blender/weapons/pistol/pistol.blend"
GLB = "assets/models/weapons/pistol/pistol.glb"


def main() -> None:
    kit.reset()
    steel = kit.material("M1911Steel", (0.07, 0.07, 0.08), 0.85, 0.32)
    steel_light = kit.material("M1911SteelLight", (0.12, 0.12, 0.13), 0.9, 0.28)
    dark = kit.material("M1911Dark", (0.02, 0.02, 0.02), 0.4, 0.55)
    wood = kit.material("M1911Grip", (0.24, 0.12, 0.06), 0.0, 0.62)

    root = kit.root()

    # Frame e slide (slide é animado pelo WeaponController).
    kit.box("Frame", root, (0.0, 0.002, 0.019), (0.028, 0.166, 0.030), steel)
    kit.box("Slide", root, (0.0, 0.004, 0.050), (0.031, 0.198, 0.034), steel_light)
    kit.box("DustCover", root, (0.0, 0.070, 0.030), (0.026, 0.040, 0.020), steel)
    kit.cylinder("Barrel", root, (0.0, 0.086, 0.050), 0.0068, 0.055, dark)
    kit.cylinder("BarrelBushing", root, (0.0, 0.101, 0.051), 0.0102, 0.012, steel_light)

    # Grip com perfil extrudado (madeira) e magazine interno.
    kit.profile("Grip", root, [
        (-0.025, 0.012), (-0.080, 0.005), (-0.095, -0.045),
        (-0.078, -0.085), (-0.035, -0.075), (-0.020, -0.025),
    ], 0.030, wood, bevel=0.004)
    kit.cylinder("GripScrewL", root, (-0.016, -0.056, -0.038), 0.004, 0.003,
                 steel, axis="X")
    kit.cylinder("GripScrewR", root, (0.016, -0.056, -0.038), 0.004, 0.003,
                 steel, axis="X")
    kit.box("Magazine", root, (0.0, -0.058, -0.040), (0.019, 0.036, 0.070),
            dark, rotation=(-0.30, 0.0, 0.0), bevel=0.001)
    kit.box("MagazineBase", root, (0.0, -0.072, -0.075), (0.024, 0.040, 0.009),
            steel, rotation=(-0.30, 0.0, 0.0), bevel=0.001)

    # Gatilho, guarda e martelo.
    kit.box("Trigger", root, (0.0, -0.004, 0.004), (0.006, 0.008, 0.024), steel,
            bevel=0.001)
    kit.box("TriggerGuardBottom", root, (0.0, -0.020, -0.016),
            (0.022, 0.070, 0.006), steel, bevel=0.002)
    kit.box("TriggerGuardFront", root, (0.0, 0.015, 0.002),
            (0.022, 0.006, 0.030), steel, bevel=0.002)
    kit.box("Hammer", root, (0.0, -0.096, 0.050), (0.010, 0.024, 0.026), steel,
            rotation=(0.55, 0.0, 0.0), bevel=0.0015)
    kit.box("Beavertail", root, (0.0, -0.092, 0.031), (0.024, 0.028, 0.011),
            steel, bevel=0.002)

    # Segurança, serrilhas do slide e miras.
    kit.cylinder("Safety", root, (-0.0155, -0.060, 0.038), 0.0065, 0.004, steel,
                 axis="X")
    for i, y in enumerate((-0.062, -0.052, -0.042, -0.032)):
        kit.box("SerrilhadoL%d" % i, root, (-0.0157, y, 0.051),
                (0.0025, 0.003, 0.028), dark, bevel=0.0)
        kit.box("SerrilhadoR%d" % i, root, (0.0157, y, 0.051),
                (0.0025, 0.003, 0.028), dark, bevel=0.0)
    kit.box("RearSight", root, (0.0, -0.082, 0.069), (0.020, 0.008, 0.009),
            dark, bevel=0.001)
    kit.box("FrontSight", root, (0.0, 0.090, 0.070), (0.004, 0.006, 0.008),
            dark, bevel=0.001)
    kit.box("EjectionPort", root, (0.0160, 0.024, 0.053),
            (0.0015, 0.042, 0.018), dark, bevel=0.0)

    kit.empty("GripSocket", root, (0.0, -0.056, -0.040))
    kit.empty("Muzzle", root, (0.0, 0.114, 0.051))

    kit.export(BLEND, GLB, ("m1911",))


main()
