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

    # Receiver tubular e bloco dianteiro (perfil extrudado).
    kit.profile("Receiver", root, [
        (-0.170, 0.008), (-0.165, 0.072), (-0.120, 0.082), (0.080, 0.082),
        (0.145, 0.072), (0.150, 0.012), (0.100, 0.004), (-0.120, 0.004),
    ], 0.058, steel, bevel=0.008)
    kit.box("RearCap", root, (0.0, -0.162, 0.040), (0.056, 0.018, 0.072),
            dark, bevel=0.004)
    kit.cylinder("CockingTube", root, (0.0, 0.170, 0.076), 0.017, 0.115,
                 steel)
    kit.cylinder("Bolt", root, (0.0, 0.205, 0.076), 0.011, 0.130, dark)

    # Guarda-mão e cano (perfil arredondado).
    kit.profile("Handguard", root, [
        (0.135, 0.068), (0.270, 0.068), (0.278, 0.040), (0.270, 0.012),
        (0.135, 0.012),
    ], 0.050, polymer, bevel=0.007)
    kit.cylinder("Barrel", root, (0.0, 0.300, 0.050), 0.0105, 0.120, dark)
    kit.cylinder("MuzzleCrown", root, (0.0, 0.356, 0.050), 0.013, 0.018, steel)

    # Punho, gatilho e guarda.
    kit.profile("PistolGrip", root, [
        (-0.120, 0.010), (-0.082, 0.010), (-0.075, -0.040),
        (-0.092, -0.095), (-0.128, -0.105), (-0.145, -0.055),
    ], 0.034, polymer, bevel=0.007)
    kit.box("Trigger", root, (0.0, -0.040, -0.002), (0.007, 0.009, 0.028),
            dark, bevel=0.001)
    kit.box("TriggerGuard", root, (0.0, -0.052, -0.026), (0.024, 0.072, 0.006),
            polymer, bevel=0.002)

    # Magazine curvo: perfil extrudado contínuo.
    kit.profile("Magazine", root, [
        (0.095, 0.005), (0.105, -0.040), (0.125, -0.090), (0.150, -0.140),
        (0.170, -0.175), (0.120, -0.185), (0.100, -0.140), (0.075, -0.090),
        (0.055, -0.040), (0.035, 0.005),
    ], 0.046, dark, bevel=0.004)

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
