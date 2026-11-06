class_name SpawnData
extends RefCounted

var id := ""
var position := Vector3.ZERO
var room := ""

static func from_dict(d: Dictionary) -> SpawnData:
	var o := SpawnData.new()
	o.id = String(d.get("id", ""))
	var p: Array = d.get("position", [0, 0, 0])
	o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	o.room = String(d.get("room", ""))
	return o
