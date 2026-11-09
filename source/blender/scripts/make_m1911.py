"""Gera a M1911 autoral low-poly (slide, frame, guarda, grip e detalhes).

Modelo de experimento: perfis extrudados + bevel + peças pequenas, mantendo
contagem baixa de polígonos. Convenção: metros, +Y frente, +Z cima.

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
    steel = kit.material("M1911Steel", (0.055, 0.060, 0.068), 0.9, 0.30)
    steel_light = kit.material("M1911SteelLight", (0.105, 0.110, 0.120), 0.92, 0.24)
    dark = kit.material("M1911Dark", (0.014, 0.014, 0.017), 0.5, 0.5)
    wood = kit.material("M1911Wood", (0.30, 0.145, 0.065), 0.0, 0.58)

    root = kit.root()

    # Slide com perfil lateral, frente chanfrada e topo reto.
    kit.profile("Slide", root, [
        (0.108, 0.006), (0.108, 0.023), (0.100, 0.030), (-0.096, 0.030),
        (-0.104, 0.023), (-0.104, 0.004), (-0.100, 0.000), (0.100, 0.000),
    ], 0.033, steel_light, bevel=0.0025)

    # Frame com dust cover e rebaixo do gatilho.
    kit.profile("Frame", root, [
        (-0.100, 0.000), (0.100, 0.000), (0.100, -0.016), (0.040, -0.020),
        (0.040, -0.029), (0.016, -0.031), (-0.030, -0.030), (-0.030, -0.020),
        (-0.100, -0.020),
    ], 0.030, steel, bevel=0.002)

    # Guarda do gatilho como anel extrudado (com furo real).
    kit.ring_profile("TriggerGuard", root, [
        (-0.028, -0.020), (-0.038, -0.038), (-0.036, -0.056),
        (-0.018, -0.066), (0.012, -0.064), (0.030, -0.052),
        (0.036, -0.034), (0.034, -0.020),
    ], [
        (0.024, -0.023), (0.024, -0.036), (0.018, -0.048),
        (0.004, -0.055), (-0.014, -0.056), (-0.026, -0.048),
        (-0.027, -0.036), (-0.016, -0.023),
    ], 0.024, steel, bevel=0.0015)

    # Grip inclinado, painéis de madeira e parafusos.
    kit.profile("Grip", root, [
        (-0.028, -0.018), (-0.088, -0.022), (-0.098, -0.080),
        (-0.048, -0.090), (-0.036, -0.055),
    ], 0.030, steel, bevel=0.003)
    panel_points = [
        (-0.038, -0.029), (-0.084, -0.032), (-0.092, -0.075),
        (-0.054, -0.082), (-0.043, -0.055),
    ]
    kit.profile("GripPanelL", root, panel_points, 0.004, wood,
                location=(-0.0155, 0.0, 0.0), bevel=0.0012)
    kit.profile("GripPanelR", root, panel_points, 0.004, wood,
                location=(0.0155, 0.0, 0.0), bevel=0.0012)
    for side, x in (("L", -0.0178), ("R", 0.0178)):
        kit.cylinder("GripScrew" + side, root, (x, -0.060, -0.047),
                     0.0032, 0.002, steel_light, axis="X")
        for i, z in enumerate((-0.040, -0.052, -0.064, -0.076)):
            kit.box("GripLine%s%d" % (side, i), root,
                    (x, -0.062 + (z + 0.058) * 0.12, z),
                    (0.0012, 0.030, 0.0012), dark, bevel=0.0)

    # Magazine interno e baseplate.
    kit.profile("Magazine", root, [
        (-0.037, -0.030), (-0.082, -0.033), (-0.090, -0.078),
        (-0.052, -0.084), (-0.041, -0.055),
    ], 0.020, dark, bevel=0.001)
    kit.box("MagazineBase", root, (0.0, -0.086, -0.086),
            (0.024, 0.032, 0.006), steel, rotation=(-0.20, 0.0, 0.0),
            bevel=0.001)

    # Gatilho com pivô no topo (para a animação girar certo).
    kit.profile("Trigger", root, [
        (-0.002, 0.000), (0.003, 0.000), (0.007, -0.020),
        (0.003, -0.033), (-0.004, -0.032), (-0.006, -0.018),
    ], 0.006, steel_light, location=(0.0, -0.014, -0.022), bevel=0.001)

    # Martelo, beavertail e comandos laterais.
    kit.profile("Hammer", root, [
        (-0.088, 0.008), (-0.097, 0.026), (-0.109, 0.033),
        (-0.114, 0.027), (-0.107, 0.016), (-0.098, 0.003),
    ], 0.010, steel, bevel=0.0015)
    kit.profile("Beavertail", root, [
        (-0.082, 0.000), (-0.102, 0.003), (-0.110, -0.008),
        (-0.102, -0.016), (-0.088, -0.010),
    ], 0.026, steel, bevel=0.002)
    kit.cylinder("ThumbSafety", root, (-0.0175, -0.077, 0.004),
                 0.0065, 0.004, steel, axis="X")
    kit.box("ThumbSafetyLever", root, (-0.0180, -0.069, 0.004),
            (0.002, 0.018, 0.008), steel, bevel=0.001)
    kit.cylinder("SlideStop", root, (-0.0175, -0.020, -0.005),
                 0.0050, 0.004, steel, axis="X")
    kit.box("SlideStopLever", root, (-0.0180, -0.010, -0.005),
            (0.002, 0.016, 0.007), steel, bevel=0.001)
    kit.cylinder("MagRelease", root, (-0.0175, -0.047, -0.024),
                 0.0040, 0.004, steel, axis="X")

    # Cano, bucha, plugue do recoil e miras.
    kit.cylinder("Barrel", root, (0.0, 0.106, 0.016), 0.0052, 0.012, dark)
    kit.cylinder("BarrelBushing", root, (0.0, 0.106, 0.016),
                 0.0105, 0.007, steel_light)
    kit.cylinder("RecoilPlug", root, (0.0, 0.106, 0.005),
                 0.0080, 0.005, steel)
    kit.box("FrontSight", root, (0.0, 0.097, 0.034),
            (0.0035, 0.005, 0.008), dark, bevel=0.0008)
    kit.box("RearSightBase", root, (0.0, -0.094, 0.0315),
            (0.020, 0.008, 0.003), dark, bevel=0.0008)
    kit.box("RearSightL", root, (-0.0062, -0.094, 0.0335),
            (0.0070, 0.006, 0.006), dark, bevel=0.0008)
    kit.box("RearSightR", root, (0.0062, -0.094, 0.0335),
            (0.0070, 0.006, 0.006), dark, bevel=0.0008)

    # Serrilhas traseiras e porta de ejeção.
    for i, y in enumerate((-0.094, -0.086, -0.078, -0.070, -0.062)):
        kit.box("SerrationL%d" % i, root, (-0.0167, y, 0.015),
                (0.0014, 0.0022, 0.022), dark, bevel=0.0)
        kit.box("SerrationR%d" % i, root, (0.0167, y, 0.015),
                (0.0014, 0.0022, 0.022), dark, bevel=0.0)
    kit.box("EjectionPort", root, (0.0167, 0.026, 0.019),
            (0.0014, 0.040, 0.016), dark, bevel=0.0)

    kit.empty("GripSocket", root, (0.0, -0.060, -0.052))
    kit.empty("Muzzle", root, (0.0, 0.112, 0.016))

    kit.export(BLEND, GLB, ("m1911-lowpoly",))


main()
