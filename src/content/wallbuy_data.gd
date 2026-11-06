class_name WallBuyData
extends RefCounted

var id := ""
var weapon_id := ""
var name := ""
var cost := 0
var position := Vector3.ZERO
var rotation_y := 0.0

static func from_dict(d: Dictionary) -> WallBuyData:
	var o := WallBuyData.new()
	o.id = String(d.get("id", ""))
	o.weapon_id = String(d.get("weapon", ""))
	o.name = String(d.get("name", ""))
	o.cost = int(d.get("cost", 0))
	var p: Array = d.get("position", [0, 0, 0])
	o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	o.rotation_y = float(d.get("rotation_y", 0.0))
	return o
