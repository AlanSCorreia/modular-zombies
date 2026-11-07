class_name ExplosiveData
extends RefCounted

var id := ""
var name := ""
var damage := 100.0
var radius := 4.0
var falloff := 0.35
var impulse := 4.0
var max_targets := 24
var chain_depth := 0

static func from_dict(d: Dictionary) -> ExplosiveData:
	var e := ExplosiveData.new()
	e.id = String(d.get("id", ""))
	e.name = String(d.get("name", ""))
	e.damage = float(d.get("damage", 100.0))
	e.radius = float(d.get("radius", 4.0))
	e.falloff = float(d.get("falloff", 0.35))
	e.impulse = float(d.get("impulse", 4.0))
	e.max_targets = int(d.get("max_targets", 24))
	e.chain_depth = int(d.get("chain_depth", 0))
	return e
