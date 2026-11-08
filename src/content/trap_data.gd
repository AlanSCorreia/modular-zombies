class_name TrapData
extends RefCounted

var id := ""
var explosive_id := ""
var position := Vector3.ZERO
var trigger_radius := 1.3

static func from_dict(d: Dictionary) -> TrapData:
	var t := TrapData.new()
	t.id = String(d.get("id", ""))
	t.explosive_id = String(d.get("explosive", ""))
	var p: Array = d.get("position", [0, 0, 0])
	t.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	t.trigger_radius = float(d.get("trigger_radius", 1.3))
	return t
