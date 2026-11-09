"""Gera a AK-74 autoral (receiver, coronha, guarda-mão, cano e magazine).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_ak74.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import weapon_kit as kit

BLEND = "source/blender/weapons/ak74/ak74.blend"
GLB = "assets/models/weapons/ak74/ak74.glb"


def main() -> None:
    kit.reset()
    steel = kit.material("AK74Steel", (0.075, 0.08, 0.085), 0.85, 0.34)
    dark = kit.material("AK74Dark", (0.025, 0.025, 0.028), 0.6, 0.48)
    wood = kit.material("AK74Wood", (0.30, 0.14, 0.055), 0.0, 0.6)
    bakelite = kit.material("AK74Mag", (0.34, 0.16, 0.07), 0.0, 0.5)

    root = kit.root()

    # Receiver e cobertura superior.
    kit.box("Receiver", root, (0.0, -0.005, 0.030), (0.062, 0.230, 0.078),
            steel, bevel=0.004)
    kit.box("DustCover", root, (0.0, -0.010, 0.073), (0.052, 0.195, 0.018),
            steel, bevel=0.005)
    kit.box("RearSight", root, (0.0, 0.118, 0.083), (0.030, 0.035, 0.014),
            dark, bevel=0.0015)
    kit.cylinder("Bolt", root, (0.038, 0.055, 0.052), 0.0065, 0.060, steel,
                 axis="Y", rotation=(0.0, 0.0, 0.0))

    # Coronha de madeira e punho (perfis extrudados).
    kit.profile("Stock", root, [
        (-0.105, 0.078), (-0.160, 0.082), (-0.270, 0.066),
        (-0.390, 0.038), (-0.398, -0.050), (-0.300, -0.040),
        (-0.180, -0.004), (-0.105, -0.012),
    ], 0.046, wood, bevel=0.007)
    kit.box("ButtPlate", root, (0.0, -0.398, -0.006), (0.050, 0.014, 0.090),
            dark, bevel=0.003)
    kit.profile("PistolGrip", root, [
        (-0.120, 0.010), (-0.078, 0.010), (-0.070, -0.045),
        (-0.090, -0.105), (-0.130, -0.118), (-0.150, -0.060),
    ], 0.036, dark, bevel=0.007)

    # Guarda-mão, tubo de gás e cano.
    kit.box("Handguard", root, (0.0, 0.212, 0.024), (0.060, 0.175, 0.062),
            wood, bevel=0.006)
    kit.box("UpperHandguard", root, (0.0, 0.212, 0.080), (0.050, 0.150, 0.034),
            wood, bevel=0.005)
    kit.cylinder("GasTube", root, (0.0, 0.220, 0.080), 0.010, 0.200, steel)
    kit.cylinder("Barrel", root, (0.0, 0.385, 0.048), 0.0095, 0.230, dark)
    kit.box("GasBlock", root, (0.0, 0.330, 0.058), (0.034, 0.040, 0.050),
            steel, bevel=0.003)
    kit.cylinder("MuzzleBrake", root, (0.0, 0.518, 0.048), 0.016, 0.052,
                 steel)

    # Massa de mira e alça.
    kit.box("FrontSightBase", root, (0.0, 0.468, 0.062), (0.030, 0.032, 0.052),
            steel, bevel=0.003)
    kit.box("FrontSightPost", root, (0.0, 0.468, 0.098), (0.006, 0.008, 0.030),
            dark, bevel=0.0)

    # Magazine curvo: um único perfil extrudado (banana contínua).
    kit.profile("Magazine", root, [
        (0.095, 0.005), (0.105, -0.050), (0.125, -0.110), (0.155, -0.170),
        (0.185, -0.220), (0.135, -0.235), (0.115, -0.180), (0.090, -0.120),
        (0.065, -0.060), (0.035, 0.005),
    ], 0.052, bakelite, bevel=0.004)

    # Gatilho e guarda.
    kit.box("Trigger", root, (0.0, -0.045, 0.000), (0.007, 0.010, 0.030),
            dark, bevel=0.001)
    kit.box("TriggerGuard", root, (0.0, -0.058, -0.024), (0.026, 0.075, 0.006),
            dark, bevel=0.002)
    kit.box("SafetyLever", root, (0.033, -0.020, 0.052), (0.008, 0.060, 0.012),
            steel, bevel=0.001)

    kit.empty("GripSocket", root, (0.0, -0.108, -0.062))
    kit.empty("Muzzle", root, (0.0, 0.550, 0.048))

    kit.export(BLEND, GLB, ("ak74",))


main()
