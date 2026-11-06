class_name PerkData
extends RefCounted

var id := ""
var name := ""
var cost := 0
var position := Vector3.ZERO
var rotation_y := 0.0
var effect := ""

static func from_dict(d: Dictionary) -> PerkData:
	var o := PerkData.new()
	o.id = String(d.get("id", ""))
	o.name = String(d.get("name", ""))
	o.cost = int(d.get("cost", 0))
	var p: Array = d.get("position", [0, 0, 0])
	o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	o.rotation_y = float(d.get("rotation_y", 0.0))
	o.effect = String(d.get("effect", ""))
	return o
