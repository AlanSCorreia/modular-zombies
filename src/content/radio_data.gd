class_name RadioData
extends RefCounted

var id := ""
var room := ""
var position := Vector3.ZERO
var rotation_y := 0.0
var quest_id := ""

static func from_dict(d: Dictionary) -> RadioData:
	var r := RadioData.new()
	r.id = String(d.get("id", ""))
	r.room = String(d.get("room", ""))
	var p: Array = d.get("position", [0, 0, 0])
	r.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	r.rotation_y = float(d.get("rotation_y", 0.0))
	r.quest_id = String(d.get("quest", ""))
	return r
