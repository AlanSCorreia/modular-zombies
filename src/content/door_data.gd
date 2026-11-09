class_name DoorData
extends RefCounted

var id := ""
var name := "ABRIR"
var cost := 0
var room := ""
var position := Vector3.ZERO
var size := Vector3(0.2, 2.5, 2.6)
var open := false
var requires_power := false

static func from_dict(d: Dictionary) -> DoorData:
	var o := DoorData.new()
	o.id = String(d.get("id", ""))
	o.name = String(d.get("name", "ABRIR"))
	o.cost = int(d.get("cost", 0))
	o.room = String(d.get("room", ""))
	var p: Array = d.get("position", [0, 1.25, 0])
	if p.size() >= 3:
		o.position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	var s: Array = d.get("size", [0.2, 2.5, 2.6])
	if s.size() >= 3:
		o.size = Vector3(float(s[0]), float(s[1]), float(s[2]))
	o.open = bool(d.get("open", false))
	o.requires_power = bool(d.get("requires_power", false))
	return o
