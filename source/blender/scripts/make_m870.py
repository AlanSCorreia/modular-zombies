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
    kit.profile("Stock", root, [
        (-0.070, 0.062), (-0.120, 0.072), (-0.240, 0.056), (-0.345, 0.030),
        (-0.350, -0.055), (-0.230, -0.038), (-0.120, -0.012), (-0.070, -0.028),
    ], 0.046, wood, bevel=0.008)
    kit.box("ButtPlate", root, (0.0, -0.350, -0.012), (0.050, 0.015, 0.092),
            dark, bevel=0.003)

    # Cano e tubo de munição.
    kit.cylinder("Barrel", root, (0.0, 0.380, 0.060), 0.014, 0.500, dark)
    kit.cylinder("MagTube", root, (0.0, 0.340, 0.026), 0.012, 0.440, dark)
    kit.box("BarrelClamp", root, (0.0, 0.520, 0.052), (0.030, 0.018, 0.054),
            steel, bevel=0.002)

    # Pump (forend) de madeira com frisos.
    pump = kit.empty("Pump", root, (0.0, 0.270, 0.028))
    kit.profile("PumpBody", pump, [
        (-0.080, 0.024), (0.080, 0.024), (0.092, 0.010), (0.088, -0.020),
        (0.070, -0.026), (-0.080, -0.026),
    ], 0.055, wood, bevel=0.008)
    for i, y in enumerate((-0.055, -0.018, 0.019, 0.056)):
        kit.box("PumpRib%d" % i, pump, (0.0, y, 0.022), (0.048, 0.014, 0.008),
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
