class_name BarrelData
extends RefCounted

var id := ""
var explosive_id := ""
var position := Vector3.ZERO

static func from_dict(d: Dictionary) -> BarrelData:
	var b := BarrelData.new()
	b.id = String(d.get("id", ""))
	b.explosive_id = String(d.get("explosive", ""))
	var p: Array = d.get("position", [0, 0, 0])
	b.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	return b
