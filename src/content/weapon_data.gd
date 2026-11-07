class_name WeaponData
extends RefCounted

var id := ""
var name := ""
var type := "hitscan"
var scene := ""
var hands := ""
var grip_profile := ""
var animation_set := ""
var moving_parts: Array[String] = []
var viewmodel: Dictionary = {}
var stats: Dictionary = {}
var projectile: Dictionary = {}
var reload: Dictionary = {}
var audio: Dictionary = {}

static func from_dict(d: Dictionary) -> WeaponData:
	var w := WeaponData.new()
	w.id = String(d.get("id", ""))
	w.name = String(d.get("name", ""))
	w.type = String(d.get("type", "hitscan"))
	w.scene = String(d.get("scene", ""))
	w.hands = String(d.get("hands", ""))
	w.grip_profile = String(d.get("grip_profile", ""))
	w.animation_set = String(d.get("animation_set", ""))
	for p in d.get("moving_parts", []):
		w.moving_parts.append(String(p))
	w.stats = d.get("stats", {})
	w.projectile = d.get("projectile", {})
	w.viewmodel = d.get("viewmodel", {})
	w.reload = d.get("reload", {})
	w.audio = d.get("audio", {})
	return w
