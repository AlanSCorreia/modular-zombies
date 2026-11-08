class_name SpecialEnemyData
extends RefCounted

var enemy_id := ""
var from_round := 2
var chance := 0.25
var max_per_round := 1

static func from_dict(d: Dictionary) -> SpecialEnemyData:
	var s := SpecialEnemyData.new()
	s.enemy_id = String(d.get("enemy", ""))
	s.from_round = int(d.get("from_round", 2))
	s.chance = float(d.get("chance", 0.25))
	s.max_per_round = int(d.get("max_per_round", 1))
	return s
