class_name ViewmodelFactory
extends RefCounted

## Monta o viewmodel: GLB da arma + o único hands.glb compartilhado.
## O socket vem da arma (`GripSocket`); sem socket, usa o offset do perfil.

const HANDS_PATH := "res://assets/models/hands/hands.glb"
const MUZZLE_FALLBACK := Vector3(0.0, 0.108, -0.1025)

const PROFILES := {
	"pistol": {
		"hands_offset": Vector3(0.0, -0.01, 0.02),
		"hands_scale": 0.42,
		"left_offset": Vector3(0.03, -0.01, 0.24),
	},
	"rifle": {
		"hands_offset": Vector3(0.0, -0.02, 0.02),
		"hands_scale": 1.0,
		"left_offset": Vector3(0.0, 0.0, 0.04),
	},
	"shotgun": {
		"hands_offset": Vector3(0.0, -0.02, 0.02),
		"hands_scale": 0.9,
		"left_offset": Vector3(0.0, 0.0, 0.06),
	},
	"rocket": {
		"hands_offset": Vector3(0.0, -0.02, 0.02),
		"hands_scale": 1.0,
		"left_offset": Vector3(0.0, 0.0, 0.08),
	},
	"wunder": {
		"hands_offset": Vector3(0.0, -0.02, 0.02),
		"hands_scale": 1.0,
		"left_offset": Vector3(0.0, 0.0, 0.04),
	},
	"knife": {
		"hands_offset": Vector3(0.0, -0.01, 0.02),
		"hands_scale": 0.9,
		"left_offset": Vector3.ZERO,
	},
}

static func build(data: WeaponData, parent: Node3D) -> Dictionary:
	var out := {
		"weapon": null,
		"hands": null,
		"hand_l": null,
		"hand_r": null,
		"grip": null,
		"muzzle": null,
	}
	if data == null or parent == null:
		return out

	var weapon: Node3D = null
	if data.scene != "":
		var weapon_scene: PackedScene = load(data.scene)
		if weapon_scene != null:
			weapon = weapon_scene.instantiate() as Node3D
			if weapon != null:
				parent.add_child(weapon)
				out.weapon = weapon

	var hands_data := _build_hands(data.hands, data.grip_profile, parent, weapon)
	out.hands = hands_data.hands
	out.hand_l = hands_data.hand_l
	out.hand_r = hands_data.hand_r
	out.grip = hands_data.grip

	var muzzle: Node3D = null
	if weapon != null:
		muzzle = weapon.find_child("Muzzle", true, false) as Node3D
	if muzzle == null:
		muzzle = Node3D.new()
		muzzle.name = "Muzzle"
		muzzle.position = MUZZLE_FALLBACK
		parent.add_child(muzzle)
	out.muzzle = muzzle
	return out

## Faca: a arma é anexada à mão direita do hands.glb compartilhado.
static func build_melee(data: MeleeData, parent: Node3D) -> Dictionary:
	var out := {
		"weapon": null,
		"hands": null,
		"hand_l": null,
		"hand_r": null,
		"grip": null,
	}
	if data == null or parent == null:
		return out

	var knife: Node3D = null
	if data.scene != "":
		var packed: PackedScene = load(data.scene)
		if packed != null:
			knife = packed.instantiate() as Node3D

	var hands_data := _build_hands(data.hands, data.grip_profile, parent)
	out.hands = hands_data.hands
	out.hand_l = hands_data.hand_l
	out.hand_r = hands_data.hand_r
	out.grip = hands_data.grip
	out.weapon = knife
	if knife == null:
		return out
	var hand_r := out.hand_r as Node3D
	if hand_r != null:
		hand_r.add_child(knife)
		knife.position = Vector3.ZERO
		knife.rotation = Vector3.ZERO
	else:
		parent.add_child(knife)
	return out

static func _build_hands(hands_path: String, profile_name: String,
		parent: Node3D, weapon: Node3D = null) -> Dictionary:
	var out := {"hands": null, "hand_l": null, "hand_r": null, "grip": null}
	var path := hands_path if hands_path != "" else HANDS_PATH
	var hands_scene: PackedScene = load(path)
	if hands_scene == null:
		return out
	var hands := hands_scene.instantiate() as Node3D
	if hands == null:
		return out
	out.hands = hands
	out.hand_l = hands.find_child("HandL", true, false)
	out.hand_r = hands.find_child("HandR", true, false)
	out.grip = hands.find_child("GripSocket", true, false)

	var profile: Dictionary = PROFILES.get(profile_name, PROFILES["rifle"])
	hands.scale = Vector3.ONE * float(profile.get("hands_scale", 1.0))
	var socket: Node3D = null
	if weapon != null:
		socket = weapon.find_child("GripSocket", true, false) as Node3D
	if socket != null:
		socket.add_child(hands)
		hands.position = Vector3.ZERO
	else:
		hands.position = profile.get("hands_offset", Vector3.ZERO)
		parent.add_child(hands)
	var hand_l := out.hand_l as Node3D
	if hand_l != null:
		hand_l.position += profile.get("left_offset", Vector3.ZERO)
	return out
