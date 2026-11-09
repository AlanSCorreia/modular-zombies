class_name BarricadeData
extends RefCounted

var id := ""
var room := ""
var position := Vector3.ZERO
var rotation_y := 0.0
var max_planks := 6
var repair_time := 0.8
var repair_points := 10
var tear_time_base := 2.2
var tear_time_round_scale := 0.08
var spawn_position := Vector3.ZERO
var climb_time := 0.9

static func from_dict(d: Dictionary) -> BarricadeData:
	var o := BarricadeData.new()
	o.id = String(d.get("id", ""))
	o.room = String(d.get("room", ""))
	var p: Array = d.get("position", [0, 0, 0])
	if p.size() >= 3:
		o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	o.rotation_y = float(d.get("rotation_y", 0.0))
	o.max_planks = int(d.get("max_planks", 6))
	o.repair_time = float(d.get("repair_time", 0.8))
	o.repair_points = int(d.get("repair_points", 10))
	o.tear_time_base = float(d.get("tear_time_base", 2.2))
	o.tear_time_round_scale = float(d.get("tear_time_round_scale", 0.08))
	var s: Array = d.get("spawn_position", [0, 0, 0])
	if s.size() >= 3:
		o.spawn_position = Vector3(float(s[0]), float(s[1]), float(s[2]))
	o.climb_time = float(d.get("climb_time", 0.9))
	return o
