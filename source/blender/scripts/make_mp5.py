"""Gera a MP5 autoral (receiver, guarda-mão, cano, coronha retrátil e magazine).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_mp5.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import weapon_kit as kit

BLEND = "source/blender/weapons/mp5/mp5.blend"
GLB = "assets/models/weapons/mp5/mp5.glb"


def main() -> None:
    kit.reset()
    steel = kit.material("MP5Steel", (0.07, 0.075, 0.08), 0.85, 0.32)
    dark = kit.material("MP5Dark", (0.03, 0.03, 0.033), 0.55, 0.48)
    polymer = kit.material("MP5Polymer", (0.055, 0.055, 0.06), 0.2, 0.62)

    root = kit.root()

    # Receiver tubular e bloco dianteiro.
    kit.box("Receiver", root, (0.0, -0.010, 0.040), (0.058, 0.300, 0.076),
            steel, bevel=0.010)
    kit.box("RearCap", root, (0.0, -0.162, 0.040), (0.056, 0.018, 0.072),
            dark, bevel=0.004)
    kit.cylinder("CockingTube", root, (0.0, 0.170, 0.076), 0.017, 0.115,
                 steel)
    kit.cylinder("Bolt", root, (0.0, 0.205, 0.076), 0.011, 0.130, dark)

    # Guarda-mão e cano.
    kit.box("Handguard", root, (0.0, 0.205, 0.038), (0.050, 0.145, 0.056),
            polymer, bevel=0.006)
    kit.cylinder("Barrel", root, (0.0, 0.300, 0.050), 0.0105, 0.120, dark)
    kit.cylinder("MuzzleCrown", root, (0.0, 0.356, 0.050), 0.013, 0.018, steel)

    # Punho, gatilho e guarda.
    kit.box("PistolGrip", root, (0.0, -0.108, -0.062), (0.034, 0.052, 0.100),
            polymer, rotation=(-0.24, 0.0, 0.0), bevel=0.006)
    kit.box("Trigger", root, (0.0, -0.040, -0.002), (0.007, 0.009, 0.028),
            dark, bevel=0.001)
    kit.box("TriggerGuard", root, (0.0, -0.052, -0.026), (0.024, 0.072, 0.006),
            polymer, bevel=0.002)

    # Magazine curvo.
    mag = kit.empty("Magazine", root, (0.0, 0.050, 0.000))
    kit.box("MagTop", mag, (0.0, 0.0, -0.025), (0.046, 0.075, 0.060),
            dark, rotation=(-0.10, 0.0, 0.0), bevel=0.003)
    kit.box("MagMid", mag, (0.0, 0.008, -0.070), (0.046, 0.070, 0.060),
            dark, rotation=(-0.26, 0.0, 0.0), bevel=0.003)
    kit.box("MagBottom", mag, (0.0, 0.024, -0.112), (0.046, 0.065, 0.060),
            dark, rotation=(-0.42, 0.0, 0.0), bevel=0.003)

    # Coronha retrátil.
    kit.cylinder("StockRailL", root, (-0.019, -0.260, 0.048), 0.005, 0.190,
                 steel)
    kit.cylinder("StockRailR", root, (0.019, -0.260, 0.048), 0.005, 0.190,
                 steel)
    kit.box("ButtPlate", root, (0.0, -0.356, 0.042), (0.046, 0.016, 0.082),
            dark, bevel=0.004)

    # Miras de tambor e anel frontal.
    kit.cylinder("RearSight", root, (0.0, -0.105, 0.090), 0.016, 0.036,
                 dark, axis="X")
    kit.torus("FrontSightRing", root, (0.0, 0.262, 0.086), 0.011, 0.0028,
              steel)
    kit.box("FrontSightPost", root, (0.0, 0.262, 0.080), (0.004, 0.004, 0.020),
            dark, bevel=0.0)

    kit.empty("GripSocket", root, (0.0, -0.108, -0.062))
    kit.empty("Muzzle", root, (0.0, 0.366, 0.050))

    kit.export(BLEND, GLB, ("mp5",))


main()
