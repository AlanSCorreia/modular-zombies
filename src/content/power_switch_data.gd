class_name PowerSwitchData
extends RefCounted

var id := ""
var room := ""
var position := Vector3.ZERO
var rotation_y := 0.0
var door_id := ""

static func from_dict(d: Dictionary) -> PowerSwitchData:
	var p := PowerSwitchData.new()
	p.id = String(d.get("id", ""))
	p.room = String(d.get("room", ""))
	var v: Array = d.get("position", [0, 0, 0])
	p.position = Vector3(float(v[0]), float(v[1]), float(v[2]))
	p.rotation_y = float(d.get("rotation_y", 0.0))
	p.door_id = String(d.get("door", ""))
	return p
