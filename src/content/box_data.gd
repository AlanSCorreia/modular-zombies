class_name BoxData
extends RefCounted

var position := Vector3.ZERO
var cost := 950

static func from_dict(d: Dictionary) -> BoxData:
	var o := BoxData.new()
	var p: Array = d.get("position", [0, 0, 0])
	o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	o.cost = int(d.get("cost", 950))
	return o
