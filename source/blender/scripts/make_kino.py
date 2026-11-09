"""Modela o mapa Kino der Toten (low-poly) e gera o JSON de conteúdo.

Referência: ../zombie-fps/docs/kino/kino_der_toten.md
Convenção: Godot X/Z no plano, Y para cima; o map_kit converte para Blender.

Uso (na raiz do projeto):
  blender -b --python source/blender/scripts/make_kino.py
"""

import json
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import map_kit as mk

BLEND = "source/blender/maps/kino/kino.blend"
GLB = "assets/models/maps/kino/kino.glb"
JSON = "content/maps/kino.json"

# (id, x1, z1, x2, z2, height, floor_mat, wall_mat)
ROOMS = [
    ("lobby", -8, -26, 8, -10, 8.0, "marble", "lobby"),
    ("conn_lower", -12, -18, -8, -12, 3.2, "stone", "hall"),
    ("lower_hall", -26, -18, -12, -8, 3.4, "stone", "hall"),
    ("alley", -30, -8, -22, 10, 6.0, "cobble", "brick"),
    ("back_room", -28, 10, -18, 18, 6.0, "wood", "brick"),
    ("conn_back_stage", -18, 12, -12, 16, 3.2, "wood", "brick"),
    ("stage", -12, 10, 12, 18, 12.0, "stage_wood", "stage"),
    ("theater", -12, 0, 12, 10, 13.0, "theater_wood", "theater"),
    ("theater_hall", -4, -10, 4, 0, 6.0, "carpet", "theater"),
    ("conn_upper", 8, -18, 10, -12, 3.2, "stone", "hall"),
    ("upper_hall", 10, -16, 22, -8, 3.4, "carpet", "portrait"),
    ("conn_upper_foyer", 14, -8, 22, -6, 3.2, "stone", "hall"),
    ("foyer", 14, -6, 24, 4, 6.0, "marble", "foyer"),
    ("conn_foyer_dressing", 14, 4, 24, 8, 3.2, "stone", "hall"),
    ("dressing_room", 14, 8, 24, 16, 3.6, "wood", "dressing"),
]

# id, name, x, z, width, height, axis, cost, target_room, open, requires_power
DOORS = [
    ("door_lobby_lower", "ABRIR", -8, -15, 3.4, 2.6, "z", 750, "lower_hall", False, False),
    ("door_lobby_upper", "ABRIR", 8, -14, 3.4, 2.6, "z", 750, "upper_hall", False, False),
    ("arch_lower_conn", "", -12, -15, 3.4, 2.9, "z", 0, "lower_hall", True, False),
    ("arch_upper_conn", "", 10, -15, 3.4, 2.9, "z", 0, "upper_hall", True, False),
    ("door_lower_alley", "ABRIR", -24, -8, 3.4, 2.6, "x", 1000, "alley", False, False),
    ("door_alley_back", "ABRIR", -25, 10, 3.4, 2.6, "x", 1250, "back_room", False, False),
    ("arch_back_conn", "", -18, 14, 3.4, 2.9, "z", 0, "back_room", True, False),
    ("door_back_stage", "ABRIR", -12, 14, 3.4, 2.6, "z", 1250, "stage", False, False),
    ("arch_dressing_conn", "", 14, 14, 3.4, 2.9, "z", 0, "dressing_room", True, False),
    ("door_dressing_stage", "ABRIR", 12, 14, 3.4, 2.6, "z", 1250, "dressing_room", False, False),
    ("door_stage_curtain", "CORTINA", 0, 10, 8.0, 4.6, "x", 0, "theater", False, True),
    ("door_lobby_theater", "TEATRO", 0, -10, 6.0, 3.2, "x", 0, "theater_hall", False, True),
    ("arch_theater_hall", "", 0, 0, 6.0, 3.6, "x", 0, "theater", True, False),
    ("door_upper_foyer", "ABRIR", 18, -8, 4.0, 2.6, "x", 1000, "foyer", False, False),
    ("arch_upper_foyer", "", 18, -6, 4.0, 2.9, "x", 0, "foyer", True, False),
    ("arch_foyer_dressing", "", 19, 4, 4.0, 2.9, "x", 0, "dressing_room", True, False),
    ("door_foyer_dressing", "ABRIR", 19, 8, 4.0, 2.6, "x", 1250, "dressing_room", False, False),
]

# id, room, x, z, rot_y, spawn_x, spawn_z
BARRICADES = [
    ("lobby_s1", "lobby", -5, -26, 0.0, -5, -27.6),
    ("lobby_s2", "lobby", 5, -26, 0.0, 5, -27.6),
    ("lobby_w1", "lobby", -8, -22, 1.5708, -9.6, -22),
    ("lower_w1", "lower_hall", -26, -15, 1.5708, -27.6, -15),
    ("lower_w2", "lower_hall", -26, -11, 1.5708, -27.6, -11),
    ("alley_w1", "alley", -30, -4, 1.5708, -31.6, -4),
    ("alley_w2", "alley", -30, 4, 1.5708, -31.6, 4),
    ("back_n1", "back_room", -24, 18, 0.0, -24, 19.6),
    ("stage_n1", "stage", -8, 18, 0.0, -8, 19.6),
    ("stage_n2", "stage", 8, 18, 0.0, 8, 19.6),
    ("theater_w1", "theater", -12, 3, 1.5708, -13.6, 3),
    ("theater_e1", "theater", 12, 6, -1.5708, 13.6, 6),
    ("upper_e1", "upper_hall", 22, -13, -1.5708, 23.6, -13),
    ("upper_e2", "upper_hall", 22, -10, -1.5708, 23.6, -10),
    ("foyer_e1", "foyer", 24, -1, -1.5708, 25.6, -1),
    ("dressing_n1", "dressing_room", 18, 16, 0.0, 18, 17.6),
    ("dressing_n2", "dressing_room", 21, 16, 0.0, 21, 17.6),
]

# id, weapon, name, cost, x, z, rot_y
WALLBUYS = [
    ("wb_lobby", "weapon.glock17", "GLOCK 17", 500, -6.5, -12, 0.0),
    ("wb_lower", "weapon.mp5", "MP5", 1000, -25.5, -13, 1.5708),
    ("wb_alley", "weapon.ak74", "AK-74", 1200, -29.5, 2, 1.5708),
    ("wb_upper", "weapon.sks", "SKS", 1000, 21.5, -12, -1.5708),
    ("wb_foyer", "weapon.m870", "M870", 1500, 23.5, 0, -1.5708),
    ("wb_dressing", "weapon.pistol", "M1911", 500, 15.2, 13, 1.5708),
    ("wb_stage", "weapon.sks", "SKS", 1200, -11.5, 16, 1.5708),
]

# id, name, cost, x, z, rot_y, effect
PERKS = [
    ("quick", "REVIVER", 1500, -6.5, -24, 0.0, "revive"),
    ("tap", "GATILHO DUPLO", 2000, -28.5, 6, 1.5708, "tap"),
    ("speed", "MÃOS RÁPIDAS", 3000, 22.5, 2, -1.5708, "speed"),
    ("jugg", "AÇO VITAL", 2500, -10.5, 4, 1.5708, "jugg"),
]

POWER_LIGHTS = [
    [0, 4.5, -18], [-5, 3.5, -23], [5, 3.5, -23],
    [0, 5, 5], [-7, 5, 5], [7, 5, 5],
    [0, 6, 14], [-8, 4, 16], [8, 4, 16],
    [18, 3, 0], [18, 3, 12], [18, 2.5, -12],
]


def main() -> None:
    mk.reset()
    mats = {
        "marble": mk.material("KinoMarble", (0.10, 0.09, 0.08), 0.35, 0.0),
        "stone": mk.material("KinoStone", (0.07, 0.065, 0.06), 0.8, 0.0),
        "cobble": mk.material("KinoCobble", (0.04, 0.04, 0.04), 0.9, 0.0),
        "wood": mk.material("KinoWood", (0.065, 0.04, 0.025), 0.7, 0.0),
        "stage_wood": mk.material("KinoStageWood", (0.085, 0.05, 0.028), 0.65, 0.0),
        "theater_wood": mk.material("KinoTheaterWood", (0.055, 0.033, 0.022), 0.7, 0.0),
        "carpet": mk.material("KinoCarpet", (0.08, 0.018, 0.02), 0.9, 0.0),
        "brick": mk.material("KinoBrick", (0.09, 0.045, 0.035), 0.9, 0.0),
        "lobby": mk.material("KinoLobbyWall", (0.095, 0.032, 0.028), 0.75, 0.0),
        "hall": mk.material("KinoHallWall", (0.10, 0.085, 0.065), 0.85, 0.0),
        "stage": mk.material("KinoStageWall", (0.05, 0.045, 0.042), 0.9, 0.0),
        "theater": mk.material("KinoTheaterWall", (0.11, 0.028, 0.033), 0.8, 0.0),
        "portrait": mk.material("KinoPortraitWall", (0.09, 0.03, 0.028), 0.8, 0.0),
        "foyer": mk.material("KinoFoyerWall", (0.115, 0.075, 0.04), 0.7, 0.0),
        "dressing": mk.material("KinoDressingWall", (0.08, 0.05, 0.045), 0.8, 0.0),
        "gold": mk.material("KinoGold", (0.25, 0.16, 0.06), 0.35, 0.7),
        "velvet": mk.material("KinoVelvet", (0.14, 0.018, 0.024), 0.85, 0.0),
        "dark": mk.material("KinoDark", (0.018, 0.017, 0.016), 0.7, 0.2),
        "glass": mk.material("KinoGlass", (0.05, 0.08, 0.09), 0.2, 0.6),
        "blue": mk.material("KinoBlueDoor", (0.03, 0.08, 0.15), 0.5, 0.5),
        "glow_blue": mk.material("KinoGlowBlue", (0.05, 0.35, 0.55), 0.2, 0.0,
                                 emission=(0.15, 0.65, 1.0), emission_strength=3.0),
        "glow_warm": mk.material("KinoGlowWarm", (0.8, 0.45, 0.15), 0.2, 0.0,
                                 emission=(1.0, 0.55, 0.18), emission_strength=2.5),
        "glow_purple": mk.material("KinoGlowPurple", (0.35, 0.1, 0.55), 0.2, 0.0,
                                   emission=(0.55, 0.15, 1.0), emission_strength=3.5),
    }

    root = mk.root("KinoRoot")

    # Pisos, tetos e paredes por sala.
    for rid, x1, z1, x2, z2, height, floor_key, wall_key in ROOMS:
        floor_mat = mats[floor_key]
        wall_mat = mats[wall_key]
        mk.floor("Floor_" + rid, root, x1, z1, x2, z2, 0.0, floor_mat)
        if height <= 6.5 and rid not in ("alley",):
            mk.ceiling("Ceiling_" + rid, root, x1, z1, x2, z2, height, wall_mat)
        _walls_for_room(root, rid, x1, z1, x2, z2, height, wall_mat)

    # Portas/arcos.
    for did, name, x, z, width, height, axis, cost, room, is_open, power in DOORS:
        slab_mat = mats["velvet"] if did == "door_stage_curtain" else mats["dark"]
        mk.door(did, root, x, z, 0.0, width, height, axis,
                mats["gold"], slab_mat, open_slab=is_open)

    # Barricadas e spawns.
    for bid, room, x, z, rot, sx, sz in BARRICADES:
        mk.barricade(bid, root, x, z, rot, mats["wood"], mats["dark"])

    # Wallbuys, perks e caixa.
    for wid, weapon, name, cost, x, z, rot in WALLBUYS:
        mk.wallbuy(wid, root, x, z, rot, mats["dark"], mats["gold"])
    for pid, name, cost, x, z, rot, effect in PERKS:
        accent = mats["glow_warm"]
        if effect == "jugg":
            accent = mats["velvet"]
        elif effect == "speed":
            accent = mats["glow_blue"]
        mk.perk_machine(pid, root, x, z, rot, mats["dark"], accent)
    mk.mystery_box(root, 5, -13, 3.14159, mats["dark"], mats["gold"],
                   mats["glow_blue"])

    # Teleporter/Pack-a-Punch decorativos no palco.
    mk.cylinder("TeleporterPad", root, 0, 0.04, 14, 1.7, 0.08,
                mats["glow_purple"], vertices=32)
    mk.cylinder("TeleporterCore", root, 0, 0.15, 14, 0.55, 0.22,
                mats["glow_purple"], vertices=24)
    for i in range(4):
        mk.box("TeleporterPylon%d" % i, root, -1.5 + i * 1.0, 0.8, 14,
               0.12, 1.6, 0.12, mats["dark"], bevel=0.0)

    _lobby_props(root, mats)
    _theater_props(root, mats)
    _stage_props(root, mats)
    _alley_props(root, mats)
    _back_room_props(root, mats)
    _foyer_props(root, mats)
    _dressing_props(root, mats)
    _hall_props(root, mats)

    # Luzes fixas; as de energia ficam no JSON.
    mk.lamp("LampLobby", root, 0, 5.5, -18, (1.0, 0.62, 0.28), 1.8, 16)
    mk.lamp("LampTheaterA", root, -6, 7, 5, (1.0, 0.55, 0.22), 1.6, 16)
    mk.lamp("LampTheaterB", root, 6, 7, 5, (1.0, 0.55, 0.22), 1.6, 16)
    mk.lamp("LampStage", root, 0, 7, 15, (0.75, 0.35, 0.9), 1.4, 14)
    mk.lamp("LampAlley", root, -27, 4, 2, (0.35, 0.55, 0.85), 1.2, 12)
    mk.lamp("LampFoyer", root, 19, 4, 0, (1.0, 0.65, 0.3), 1.4, 12)

    mk.export(BLEND, GLB, ("kino",))
    _write_json()


def _wall_openings(rid: str, axis: str, fixed: float, a1: float, a2: float):
    """Aberturas de portas/barricadas numa parede."""
    ops = []
    for did, name, x, z, width, height, daxis, cost, room, is_open, power in DOORS:
        if daxis != axis or abs((z if axis == "x" else x) - fixed) > 0.8:
            continue
        center = x if axis == "x" else z
        if center < a1 - 0.8 or center > a2 + 0.8:
            continue
        ops.append((center - width * 0.5, center + width * 0.5, 0.0, height))
    for bid, room, x, z, rot, sx, sz in BARRICADES:
        if room != rid:
            continue
        if axis == "x":
            if abs(z - fixed) > 0.8 or abs(rot) > 0.1:
                continue
            center = x
        else:
            if abs(x - fixed) > 0.8 or abs(abs(rot) - 1.5708) > 0.2:
                continue
            center = z
        if center < a1 - 0.8 or center > a2 + 0.8:
            continue
        ops.append((center - 1.1, center + 1.1, 1.0, 2.9))
    return ops


def _walls_for_room(root, rid, x1, z1, x2, z2, height, mat):
    t = 0.22
    mk.wall_z("Wall_%s_W" % rid, root, z1, z2, x1 + 0.11, 0.0, height, t, mat,
              _wall_openings(rid, "z", x1, z1, z2))
    mk.wall_z("Wall_%s_E" % rid, root, z1, z2, x2 - 0.11, 0.0, height, t, mat,
              _wall_openings(rid, "z", x2, z1, z2))
    mk.wall_x("Wall_%s_S" % rid, root, x1, x2, z1 + 0.11, 0.0, height, t, mat,
              _wall_openings(rid, "x", z1, x1, x2))
    mk.wall_x("Wall_%s_N" % rid, root, x1, x2, z2 - 0.11, 0.0, height, t, mat,
              _wall_openings(rid, "x", z2, x1, x2))


def _lobby_props(root, mats):
    mk.box("LobbyBar", root, -4.2, 0.55, -24.0, 4.2, 1.1, 0.9,
           mats["wood"], bevel=0.03)
    mk.box("LobbyBarTop", root, -4.2, 1.12, -24.0, 4.4, 0.08, 1.0,
           mats["gold"], bevel=0.0)
    mk.cylinder("ChandelierLobby", root, 0, 5.8, -18, 0.55, 0.25,
                mats["gold"], vertices=24)
    for i in range(6):
        a = i * math.tau / 6.0
        mk.sphere("ChandelierBulb%d" % i, root,
                  math.cos(a) * 0.75, 5.55, -18 + math.sin(a) * 0.75,
                  0.09, mats["glow_warm"])
    mk.cylinder("MainframePad", root, 0, 0.04, -14, 1.5, 0.08,
                mats["glow_blue"], vertices=32)
    mk.box("MainframeDesk", root, 4.5, 0.55, -12.2, 2.6, 1.1, 0.8,
           mats["wood"], bevel=0.02)
    for i in range(3):
        mk.box("LobbyPoster%d" % i, root, -7.8, 2.1 + i * 0.4, -20 + i * 3.0,
               0.06, 1.0, 1.6, mats["velvet"], bevel=0.0)
    # Mezanino decorativo (sem rota).
    mk.box("Mezzanine", root, 0, 4.2, -24, 14.0, 0.25, 2.2,
           mats["wood"], bevel=0.0)
    for x in (-6.5, -3.5, 3.5, 6.5):
        mk.box("MezzRail%d" % int(x * 10), root, x, 4.8, -23.0,
               0.08, 1.0, 0.08, mats["gold"], bevel=0.0)


def _theater_props(root, mats):
    # Poltronas em dois blocos, corredor central livre.
    for side in (-1, 1):
        for row in range(5):
            for col in range(3):
                x = side * (2.4 + col * 0.75)
                z = 2.0 + row * 1.15
                mk.box("Seat_%d_%d_%d" % (side, row, col), root,
                       x, 0.28, z, 0.58, 0.55, 0.55, mats["velvet"],
                       bevel=0.02)
                mk.box("SeatBack_%d_%d_%d" % (side, row, col), root,
                       x, 0.62, z + 0.23, 0.58, 0.65, 0.12,
                       mats["velvet"], bevel=0.02)
    # Balcões/camarotes decorativos.
    for side in (-1, 1):
        mk.box("Balcony%d" % side, root, side * 9.6, 4.2, 5.0,
               4.4, 0.3, 8.0, mats["wood"], bevel=0.0)
        mk.box("BalconyRail%d" % side, root, side * 7.5, 4.8, 5.0,
               0.1, 1.0, 8.0, mats["gold"], bevel=0.0)
    # Lustres.
    for side in (-1, 1):
        mk.cylinder("ChandelierT%d" % side, root, side * 5.8, 7.2, 5.0,
                    0.4, 0.2, mats["gold"], vertices=20)
        for i in range(5):
            a = i * math.tau / 5.0
            mk.sphere("ChandelierTBulb%d_%d" % (side, i), root,
                      side * 5.8 + math.cos(a) * 0.55, 7.0,
                      5.0 + math.sin(a) * 0.55, 0.08, mats["glow_warm"])
    # Tela sobre o palco.
    mk.box("CinemaScreen", root, 0, 6.0, 10.0, 12.0, 5.2, 0.08,
           mats["glass"], bevel=0.0)
    mk.box("CinemaScreenFrame", root, 0, 6.0, 10.1, 12.6, 5.6, 0.12,
           mats["gold"], bevel=0.0)
    # Entulho/fogo.
    mk.box("TheaterDebris1", root, -10.0, 0.2, 9.0, 1.2, 0.4, 0.8,
           mats["wood"], bevel=0.0)
    mk.box("TheaterDebris2", root, 10.0, 0.15, 1.2, 0.8, 0.3, 1.4,
           mats["wood"], bevel=0.0)


def _stage_props(root, mats):
    # Arco de proscênio.
    for x in (-11.2, 11.2):
        mk.box("Proscenium%d" % int(x * 10), root, x, 3.0, 10.2,
               0.6, 6.0, 0.6, mats["gold"], bevel=0.02)
    mk.box("ProsceniumTop", root, 0, 6.1, 10.2, 23.0, 0.6, 0.6,
           mats["gold"], bevel=0.02)
    # Cortinas laterais e fundo.
    for side in (-1, 1):
        mk.box("CurtainSide%d" % side, root, side * 4.6, 2.6, 10.4,
               0.8, 4.8, 0.2, mats["velvet"], bevel=0.0)
    mk.box("Backdrop", root, 0, 5.0, 17.8, 23.0, 10.0, 0.15,
           mats["dark"], bevel=0.0)
    # Caixotes e sacos de areia.
    for i in range(4):
        mk.box("StageCrate%d" % i, root, -9.5 + i * 1.1, 0.45, 16.5,
               0.9, 0.9, 0.9, mats["wood"], bevel=0.02)
    mk.box("Sandbags1", root, 9.0, 0.35, 16.8, 2.0, 0.7, 0.8,
           mats["dark"], bevel=0.03)
    mk.box("PowerPanel", root, -9.8, 1.4, 17.7, 1.2, 2.0, 0.12,
           mats["dark"], bevel=0.0)
    mk.box("PowerPanelGlow", root, -9.8, 1.8, 17.6, 0.8, 0.2, 0.03,
           mats["glow_blue"], bevel=0.0)


def _alley_props(root, mats):
    mk.box("Dumpster", root, -27.0, 0.8, 0.0, 2.4, 1.5, 1.3,
           mats["dark"], bevel=0.03)
    mk.box("DumpsterLid", root, -27.0, 1.62, 0.0, 2.5, 0.12, 1.4,
           mats["blue"], bevel=0.02)
    mk.box("BlueDoor", root, -29.75, 1.25, 4.0, 0.12, 2.5, 1.4,
           mats["blue"], bevel=0.0)
    for i in range(5):
        mk.box("FencePost%d" % i, root, -29.7, 1.0, -6 + i * 2.4,
               0.08, 2.0, 0.08, mats["dark"], bevel=0.0)
    mk.box("FenceRail", root, -29.7, 1.8, 0.0, 0.06, 0.08, 12.0,
           mats["dark"], bevel=0.0)
    mk.box("AlleyCrate1", root, -23.5, 0.5, 7.0, 1.0, 1.0, 1.0,
           mats["wood"], bevel=0.02)
    mk.box("AlleyCrate2", root, -23.5, 0.4, 8.2, 0.8, 0.8, 0.8,
           mats["wood"], bevel=0.02)


def _back_room_props(root, mats):
    for i in range(4):
        mk.box("Flat%d" % i, root, -19.0 + i * 0.4, 2.0, 13.0 + i * 1.2,
               0.15, 4.0, 2.4, mats["wood"], bevel=0.0)
    for i in range(3):
        mk.box("BackCrate%d" % i, root, -26.5 + i * 1.1, 0.5, 16.5,
               0.9, 0.9, 0.9, mats["wood"], bevel=0.02)
    mk.box("BackShelf", root, -18.8, 1.0, 16.5, 0.4, 2.0, 3.2,
           mats["wood"], bevel=0.0)


def _foyer_props(root, mats):
    mk.box("FoyerBar", root, 16.0, 0.55, -5.2, 4.0, 1.1, 0.9,
           mats["wood"], bevel=0.03)
    mk.cylinder("FoyerChandelier", root, 19.0, 5.0, 0.0, 0.45, 0.2,
                mats["gold"], vertices=20)
    for i in range(5):
        a = i * math.tau / 5.0
        mk.sphere("FoyerBulb%d" % i, root,
                  19.0 + math.cos(a) * 0.6, 4.8,
                  math.sin(a) * 0.6, 0.08, mats["glow_warm"])
    for i in range(3):
        mk.box("FoyerMirror%d" % i, root, 23.8, 2.0, -3.0 + i * 2.2,
               0.06, 2.2, 1.2, mats["glass"], bevel=0.0)


def _dressing_props(root, mats):
    for i in range(2):
        mk.box("DressingMirror%d" % i, root, 23.7, 1.7, 10.0 + i * 2.2,
               0.06, 2.0, 1.4, mats["glass"], bevel=0.0)
    for i, (x, z) in enumerate(((18.0, 10.0), (19.5, 12.0), (21.0, 9.5))):
        mk.cylinder("MannequinBody%d" % i, root, x, 0.9, z, 0.18, 1.4,
                    mats["dark"], vertices=12)
        mk.sphere("MannequinHead%d" % i, root, x, 1.75, z, 0.16,
                  mats["dark"])
    mk.box("CostumeRack", root, 15.2, 1.0, 15.0, 3.2, 2.0, 0.12,
           mats["wood"], bevel=0.0)


def _hall_props(root, mats):
    # Retratos do Upper Hall.
    for i in range(4):
        mk.box("Portrait%d" % i, root, 21.8, 2.1, -14.0 + i * 1.8,
               0.08, 1.4, 1.0, mats["gold"], bevel=0.0)
        mk.box("PortraitCanvas%d" % i, root, 21.75, 2.1, -14.0 + i * 1.8,
               0.03, 1.1, 0.75, mats["velvet"], bevel=0.0)
    # Canos nos corredores.
    mk.cylinder("PipeLower", root, -20.0, 2.8, -13.0, 0.12, 8.0,
                mats["dark"], vertices=12)
    mk.cylinder("PipeUpper", root, 16.0, 2.7, -13.0, 0.12, 6.0,
                mats["dark"], vertices=12)


def _write_json() -> None:
    rooms = []
    for rid, x1, z1, x2, z2, height, _, _ in ROOMS:
        rooms.append({"id": rid, "rect": [x1, z1, x2, z2], "height": height})

    doors = []
    for did, name, x, z, width, height, axis, cost, room, is_open, power in DOORS:
        size = [width, height, 0.3] if axis == "x" else [0.3, height, width]
        entry = {
            "id": did,
            "name": name if name else "PASSAGEM",
            "cost": cost,
            "room": room,
            "position": [x, 1.3, z],
            "size": size,
        }
        if is_open:
            entry["open"] = True
        if power:
            entry["requires_power"] = True
        doors.append(entry)

    barricades = []
    spawns = []
    for bid, room, x, z, rot, sx, sz in BARRICADES:
        barricades.append({
            "id": bid,
            "room": room,
            "position": [x, 1.5, z],
            "rotation_y": rot,
            "max_planks": 6,
            "repair_time": 0.8,
            "repair_points": 10,
            "spawn_position": [sx, 0.1, sz],
        })
        spawns.append({
            "id": "spawn_" + bid,
            "position": [sx, 0.1, sz],
            "room": room,
        })

    wallbuys = []
    for wid, weapon, name, cost, x, z, rot in WALLBUYS:
        wallbuys.append({
            "id": wid,
            "weapon": weapon,
            "name": name,
            "cost": cost,
            "position": [x, 1.45, z],
            "rotation_y": rot,
        })

    perks = []
    for pid, name, cost, x, z, rot, effect in PERKS:
        perks.append({
            "id": pid,
            "name": name,
            "cost": cost,
            "position": [x, 0.0, z],
            "rotation_y": rot,
            "effect": effect,
        })

    data = {
        "schema_version": 1,
        "kind": "map",
        "id": "map.kino",
        "name": "Kino der Toten",
        "builder": "scene",
        "scene": "res://assets/models/maps/kino/kino.glb",
        "player_spawn": [0.0, 0.1, -18.0],
        "starting_points": 500,
        "enemy": "enemy.zombie",
        "starting_weapon": "weapon.glock17",
        "zombie_count": 8,
        "rooms": rooms,
        "doors": doors,
        "zombie_spawns": spawns,
        "barricades": barricades,
        "barrels": [
            {"id": "barrel_alley", "explosive": "explosive.frag",
             "position": [-24.5, 0.55, 6.0]},
            {"id": "barrel_stage", "explosive": "explosive.frag",
             "position": [8.5, 0.55, 15.5]},
        ],
        "traps": [
            {"id": "trap_lower", "explosive": "explosive.frag",
             "position": [-20.0, 0.1, -13.0], "trigger_radius": 1.3},
        ],
        "radios": [],
        "power_switches": [
            {"id": "power_stage", "room": "stage",
             "position": [-9.8, 1.4, 17.2], "rotation_y": 0.0,
             "door": "door_lobby_theater"},
        ],
        "power_lights": POWER_LIGHTS,
        "special_enemies": [
            {"enemy": "enemy.brute", "from_round": 3, "chance": 0.3,
             "max_per_round": 1},
        ],
        "wallbuys": wallbuys,
        "perks": perks,
        "box": {"position": [5.0, 0.0, -13.0], "cost": 950},
        "environment": {
            "ambient_energy": 0.35,
            "exposure": 0.95,
            "fog_density": 0.006,
            "moon_energy": 0.15,
        },
    }
    Path(JSON).parent.mkdir(parents=True, exist_ok=True)
    Path(JSON).write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("KINO_JSON_OK", JSON)


main()
