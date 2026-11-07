class_name MeleeData
extends RefCounted

var id := ""
var name := ""
var damage := 0.0
var range := 1.6
var arc_deg := 100.0
var cooldown := 0.6
var impact_time := 0.18
var lunge := 0.4
var scene := ""
var hands := ""

static func from_dict(d: Dictionary) -> MeleeData:
	var m := MeleeData.new()
	m.id = String(d.get("id", ""))
	m.name = String(d.get("name", ""))
	m.damage = float(d.get("damage", 0.0))
	m.range = float(d.get("range", 1.6))
	m.arc_deg = float(d.get("arc_deg", 100.0))
	m.cooldown = float(d.get("cooldown", 0.6))
	m.impact_time = float(d.get("impact_time", 0.18))
	m.lunge = float(d.get("lunge", 0.4))
	m.scene = String(d.get("scene", ""))
	m.hands = String(d.get("hands", ""))
	return m
