class_name EnemyData
extends RefCounted

var id := ""
var name := ""
var scene := ""
var health := 100.0
var speed := 1.35
var damage := 20.0
var attack_range := 1.55
var attack_cooldown := 1.9
var scale := 0.4
var head_height := 1.46

static func from_dict(d: Dictionary) -> EnemyData:
	var e := EnemyData.new()
	e.id = String(d.get("id", ""))
	e.name = String(d.get("name", ""))
	e.scene = String(d.get("scene", ""))
	e.health = float(d.get("health", 100.0))
	e.speed = float(d.get("speed", 1.35))
	e.damage = float(d.get("damage", 20.0))
	e.attack_range = float(d.get("attack_range", 1.55))
	e.attack_cooldown = float(d.get("attack_cooldown", 1.9))
	e.scale = float(d.get("scale", 0.4))
	e.head_height = float(d.get("head_height", 1.46))
	return e
