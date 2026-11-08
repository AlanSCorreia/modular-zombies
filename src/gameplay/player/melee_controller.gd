class_name MeleeController
extends Node

var data: MeleeData
var camera: Camera3D
var player: PlayerController
var holder: Node3D
var viewmodel: Node3D
var knife: Node3D
var hands: Node3D
var hand_r: Node3D
var hand_l: Node3D

var _cooldown := 0.0
var _v_down := false
var _base_pos := Vector3.ZERO
var _base_rot := Vector3.ZERO
var _swing_tween: Tween

func setup(p_data: MeleeData, p_camera: Camera3D, p_player: PlayerController) -> void:
	data = p_data
	camera = p_camera
	player = p_player
	_build_viewmodel()

func _build_viewmodel() -> void:
	if data == null or camera == null:
		return
	holder = Node3D.new()
	holder.name = "MeleeHolder"
	holder.position = Vector3(0.18, -0.19, -0.05)
	camera.add_child(holder)

	viewmodel = Node3D.new()
	viewmodel.name = "KnifeViewmodel"
	var vm_pos: Array = data.viewmodel.get("position", [0.18, -0.20, -0.48])
	viewmodel.position = Vector3(
		float(vm_pos[0]), float(vm_pos[1]), float(vm_pos[2])
	)
	var vm_rot: Array = data.viewmodel.get("rotation", [0.0, 0.08, 0.0])
	viewmodel.rotation = Vector3(
		float(vm_rot[0]), float(vm_rot[1]), float(vm_rot[2])
	)
	var vm_scale := float(data.viewmodel.get("scale", 0.9))
	viewmodel.scale = Vector3(vm_scale, vm_scale, vm_scale)
	holder.add_child(viewmodel)

	var built := ViewmodelFactory.build_melee(data, viewmodel)
	knife = built.weapon
	hands = built.hands
	hand_r = built.hand_r
	hand_l = built.hand_l
	if hand_l != null:
		hand_l.visible = false
	viewmodel.visible = false
	_base_pos = viewmodel.position
	_base_rot = viewmodel.rotation

func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	if data == null or player == null or not player.can_control or player.is_dead:
		return
	var v := Input.is_physical_key_pressed(KEY_V)
	if v and not _v_down:
		try_swing()
	_v_down = v

func try_swing() -> bool:
	if data == null or camera == null or player == null or player.is_dead or _cooldown > 0.0:
		return false
	_cooldown = data.cooldown
	_play_swing()

	var from := camera.global_position
	var dir := -camera.global_transform.basis.z
	var to := from + dir * data.range
	var q := PhysicsRayQueryParameters3D.create(from, to, 1 | 4 | 16)
	q.collide_with_areas = false
	var res: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(q)
	if res.is_empty():
		return false
	var col = res.collider
	if col is ZombieEnemy:
		var z: ZombieEnemy = col
		z.take_damage(data.damage, false, res.position)
		Events.hitmarker.emit()
		Sfx.play_3d("hit_flesh", res.position, -4, 1.0, 0.05)
		return true
	if col is ExplosiveBarrel:
		var barrel: ExplosiveBarrel = col
		barrel.hit(data.damage)
		return true
	if col is ExplosiveTrap:
		var trap: ExplosiveTrap = col
		trap.hit(data.damage)
		return true
	return false

func _play_swing() -> void:
	if viewmodel == null:
		return
	if _swing_tween != null and _swing_tween.is_valid():
		_swing_tween.kill()
	viewmodel.visible = true
	viewmodel.position = _base_pos
	viewmodel.rotation = _base_rot
	_swing_tween = create_tween()
	_swing_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_swing_tween.tween_property(
		viewmodel, "rotation", _base_rot + Vector3(0.25, 0.7, -0.65), 0.12
	)
	_swing_tween.parallel().tween_property(
		viewmodel, "position", _base_pos + Vector3(-0.18, 0.06, -0.05), 0.12
	)
	_swing_tween.set_ease(Tween.EASE_IN)
	_swing_tween.tween_property(viewmodel, "rotation", _base_rot, 0.18)
	_swing_tween.parallel().tween_property(viewmodel, "position", _base_pos, 0.18)
	_swing_tween.tween_callback(func(): viewmodel.visible = false)
