class_name RoomData
extends RefCounted

var id := ""
var rect := Rect2()
var height := 3.2

static func from_dict(d: Dictionary) -> RoomData:
	var r := RoomData.new()
	r.id = String(d.get("id", ""))
	var a: Array = d.get("rect", [-5, -5, 5, 5])
	if a.size() >= 4:
		r.rect = Rect2(float(a[0]), float(a[1]), float(a[2]) - float(a[0]), float(a[3]) - float(a[1]))
	r.height = float(d.get("height", 3.2))
	return r
