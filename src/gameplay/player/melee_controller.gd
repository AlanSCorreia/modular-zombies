class_name MeleeController
extends Node

var data: MeleeData
var camera: Camera3D
var player: PlayerController
var _cooldown := 0.0
var _v_down := false

func setup(p_data: MeleeData, p_camera: Camera3D, p_player: PlayerController) -> void:
	data = p_data
	camera = p_camera
	player = p_player

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
	return false
