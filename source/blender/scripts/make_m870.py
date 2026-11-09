"""Gera a M870 autoral (receiver, coronha, cano, tubo e pump).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_m870.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import weapon_kit as kit

BLEND = "source/blender/weapons/m870/m870.blend"
GLB = "assets/models/weapons/m870/m870.glb"


def main() -> None:
    kit.reset()
    steel = kit.material("M870Steel", (0.065, 0.07, 0.075), 0.85, 0.33)
    dark = kit.material("M870Dark", (0.025, 0.025, 0.028), 0.5, 0.5)
    wood = kit.material("M870Wood", (0.27, 0.12, 0.05), 0.0, 0.58)

    root = kit.root()

    # Receiver e coronha.
    kit.box("Receiver", root, (0.0, 0.020, 0.030), (0.056, 0.180, 0.088),
            steel, bevel=0.006)
    kit.box("Stock", root, (0.0, -0.205, 0.008), (0.046, 0.270, 0.082),
            wood, rotation=(0.05, 0.0, 0.0), bevel=0.008)
    kit.box("ButtPlate", root, (0.0, -0.345, 0.000), (0.050, 0.015, 0.092),
            dark, bevel=0.003)
    kit.box("Wrist", root, (0.0, -0.080, -0.006), (0.040, 0.075, 0.055),
            wood, rotation=(-0.18, 0.0, 0.0), bevel=0.007)

    # Cano e tubo de munição.
    kit.cylinder("Barrel", root, (0.0, 0.380, 0.060), 0.014, 0.500, dark)
    kit.cylinder("MagTube", root, (0.0, 0.340, 0.026), 0.012, 0.440, dark)
    kit.box("BarrelClamp", root, (0.0, 0.520, 0.052), (0.030, 0.018, 0.054),
            steel, bevel=0.002)

    # Pump (forend) de madeira com frisos.
    pump = kit.empty("Pump", root, (0.0, 0.270, 0.028))
    kit.box("PumpBody", pump, (0.0, 0.0, 0.0), (0.055, 0.165, 0.048),
            wood, bevel=0.008)
    for i, y in enumerate((-0.055, -0.018, 0.019, 0.056)):
        kit.box("PumpRib%d" % i, pump, (0.0, y, 0.026), (0.048, 0.014, 0.008),
                dark, bevel=0.001)

    # Gatilho, guarda e mira de pérola.
    kit.box("Trigger", root, (0.0, -0.020, -0.020), (0.007, 0.010, 0.028),
            dark, bevel=0.001)
    kit.box("TriggerGuard", root, (0.0, -0.032, -0.040), (0.026, 0.080, 0.006),
            steel, bevel=0.002)
    kit.sphere("BeadSight", root, (0.0, 0.610, 0.077), 0.0045, steel)
    kit.box("EjectionPort", root, (0.0285, 0.055, 0.045),
            (0.0015, 0.055, 0.024), dark, bevel=0.0)

    kit.empty("GripSocket", root, (0.0, -0.075, -0.012))
    kit.empty("Muzzle", root, (0.0, 0.632, 0.060))

    kit.export(BLEND, GLB, ("m870",))


main()
