"""Gera a Wunder autoral (arma de energia com núcleo e bobinas).

O mesmo GLB serve à Wunder e ao lança-foguete (ver content/weapons/rocket.json).

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_wunder.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import weapon_kit as kit

BLEND = "source/blender/weapons/wunder/wunder.blend"
GLB = "assets/models/weapons/wunder/wunder.glb"


def main() -> None:
    kit.reset()
    steel = kit.material("WunderSteel", (0.06, 0.065, 0.075), 0.9, 0.3)
    dark = kit.material("WunderDark", (0.022, 0.024, 0.03), 0.6, 0.45)
    glow = kit.material("WunderCore", (0.05, 0.35, 0.45), 0.2, 0.25,
                        emission=(0.10, 0.85, 1.0), emission_strength=3.5)
    glow_soft = kit.material("WunderGlow", (0.08, 0.30, 0.38), 0.1, 0.3,
                             emission=(0.05, 0.60, 0.90), emission_strength=2.0)

    root = kit.root()

    # Corpo principal (perfil extrudado) e painéis laterais.
    kit.profile("Body", root, [
        (-0.195, 0.020), (-0.175, 0.095), (0.095, 0.102), (0.175, 0.078),
        (0.180, 0.020), (0.120, 0.000), (-0.050, 0.000), (-0.130, 0.010),
    ], 0.076, steel, bevel=0.008)
    kit.box("SidePanelL", root, (-0.039, -0.010, 0.050),
            (0.006, 0.220, 0.070), dark, bevel=0.003)
    kit.box("SidePanelR", root, (0.039, -0.010, 0.050),
            (0.006, 0.220, 0.070), dark, bevel=0.003)
    kit.box("TopRail", root, (0.0, 0.000, 0.108), (0.040, 0.240, 0.014),
            dark, bevel=0.002)

    # Cano, núcleo e bobinas emissivas.
    kit.cylinder("BarrelShroud", root, (0.0, 0.300, 0.060), 0.038, 0.230,
                 steel)
    kit.cylinder("Core", root, (0.0, 0.330, 0.060), 0.023, 0.280, glow)
    for i, y in enumerate((0.215, 0.275, 0.335, 0.395)):
        kit.torus("Coil%d" % i, root, (0.0, y, 0.060), 0.041, 0.006,
                  glow_soft)
    kit.cylinder("MuzzleRing", root, (0.0, 0.458, 0.060), 0.045, 0.032,
                 dark)
    kit.cylinder("MuzzleGlow", root, (0.0, 0.470, 0.060), 0.030, 0.012,
                 glow)

    # Punho e célula de energia.
    kit.profile("PistolGrip", root, [
        (-0.135, 0.012), (-0.095, 0.012), (-0.085, -0.045),
        (-0.105, -0.100), (-0.145, -0.110), (-0.160, -0.055),
    ], 0.038, dark, bevel=0.007)
    mag = kit.empty("Magazine", root, (0.0, -0.005, -0.060))
    kit.box("CellBody", mag, (0.0, 0.0, 0.0), (0.050, 0.070, 0.095),
            steel, bevel=0.004)
    kit.box("CellGlow", mag, (0.0, 0.0, -0.010), (0.036, 0.050, 0.070),
            glow_soft, bevel=0.002)

    # Gatilho e guarda.
    kit.box("Trigger", root, (0.0, -0.048, -0.004), (0.007, 0.010, 0.030),
            dark, bevel=0.001)
    kit.box("TriggerGuard", root, (0.0, -0.060, -0.030), (0.026, 0.080, 0.006),
            steel, bevel=0.002)

    # Coronha curta com almofada.
    kit.cylinder("StockRailL", root, (-0.024, -0.235, 0.052), 0.006, 0.140,
                 steel)
    kit.cylinder("StockRailR", root, (0.024, -0.235, 0.052), 0.006, 0.140,
                 steel)
    kit.box("ButtPlate", root, (0.0, -0.312, 0.050), (0.050, 0.016, 0.086),
            dark, bevel=0.004)

    # Mira/scope com lente emissiva.
    kit.cylinder("Scope", root, (0.0, 0.020, 0.124), 0.020, 0.130, dark)
    kit.cylinder("ScopeLens", root, (0.0, 0.090, 0.124), 0.016, 0.008, glow)
    kit.box("ScopeMountFront", root, (0.0, 0.060, 0.104),
            (0.022, 0.020, 0.024), steel, bevel=0.002)
    kit.box("ScopeMountRear", root, (0.0, -0.025, 0.104),
            (0.022, 0.020, 0.024), steel, bevel=0.002)

    kit.empty("GripSocket", root, (0.0, -0.118, -0.060))
    kit.empty("Muzzle", root, (0.0, 0.486, 0.060))

    kit.export(BLEND, GLB, ("wunder",))


main()
