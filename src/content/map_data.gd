class_name MapData
extends RefCounted

var id := ""
var name := ""
var builder := "scene"
var scene := ""
var player_spawn := Vector3.ZERO
var starting_points := 500
var enemy_id := ""
var zombie_count := 1
var rooms: Array[RoomData] = []
var doors: Array[DoorData] = []
var zombie_spawns: Array[SpawnData] = []
var wallbuys: Array[WallBuyData] = []
var perks: Array[PerkData] = []
var box: BoxData = null
var barricades: Array[BarricadeData] = []
var barrels: Array[BarrelData] = []
var traps: Array[TrapData] = []
var radios: Array[RadioData] = []
var power_switches: Array[PowerSwitchData] = []
var power_lights: Array[Vector3] = []

static func from_dict(d: Dictionary) -> MapData:
	var m := MapData.new()
	m.id = String(d.get("id", ""))
	m.name = String(d.get("name", ""))
	m.builder = String(d.get("builder", "scene"))
	m.scene = String(d.get("scene", ""))
	var p: Array = d.get("player_spawn", [0, 0.1, 0])
	m.player_spawn = Vector3(float(p[0]), float(p[1]), float(p[2]))
	m.starting_points = int(d.get("starting_points", 500))
	m.enemy_id = String(d.get("enemy", ""))
	m.zombie_count = int(d.get("zombie_count", 1))
	for r in d.get("rooms", []):
		m.rooms.append(RoomData.from_dict(r))
	for door in d.get("doors", []):
		m.doors.append(DoorData.from_dict(door))
	for s in d.get("zombie_spawns", []):
		m.zombie_spawns.append(SpawnData.from_dict(s))
	for w in d.get("wallbuys", []):
		m.wallbuys.append(WallBuyData.from_dict(w))
	for perk in d.get("perks", []):
		m.perks.append(PerkData.from_dict(perk))
	if d.has("box"):
		m.box = BoxData.from_dict(d.get("box", {}))
	for b in d.get("barricades", []):
		m.barricades.append(BarricadeData.from_dict(b))
	for b in d.get("barrels", []):
		m.barrels.append(BarrelData.from_dict(b))
	for t in d.get("traps", []):
		m.traps.append(TrapData.from_dict(t))
	for r in d.get("radios", []):
		m.radios.append(RadioData.from_dict(r))
	for sw in d.get("power_switches", []):
		m.power_switches.append(PowerSwitchData.from_dict(sw))
	for l in d.get("power_lights", []):
		m.power_lights.append(Vector3(float(l[0]), float(l[1]), float(l[2])))
	return m
