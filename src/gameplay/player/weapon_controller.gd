class_name WeaponController
extends Node

static var _tracer_mesh: BoxMesh
static var _tracer_mat: StandardMaterial3D

var data: WeaponData
var camera: Camera3D
var player: PlayerController
var holder: Node3D
var viewmodel: Node3D
var anim: AnimationPlayer
var slide: Node3D
var mag: Node3D
var trigger: Node3D
var hand_l: Node3D
var muzzle: Node3D
var flash_light: OmniLight3D
var flash_mesh: MeshInstance3D

var active := true
var slot_index := -1
var ammo_mag := 0
var ammo_reserve := 0
var _next_fire := 0
var _reloading := false
var _reload_left := 0.0
var _reload_total := 0.0
var _kick := 0.0
var _flash := 0.0
var _trigger_down := false
var _base_pos := Vector3.ZERO

func setup(p_data: WeaponData, p_camera: Camera3D, p_player: PlayerController) -> void:
	data = p_data
	camera = p_camera
	player = p_player
	ammo_mag = int(data.stats.get("mag", 17))
	ammo_reserve = int(data.stats.get("reserve", 102))

	holder = Node3D.new()
	holder.position = Vector3(0.18, -0.19, -0.05)
	camera.add_child(holder)
	_base_pos = holder.position

	viewmodel = Node3D.new()
	viewmodel.position = Vector3(0.06, -0.14, -0.62)
	viewmodel.rotation.y = 0.08
	var vm_scale := float(data.viewmodel.get("scale", 0.78))
	viewmodel.scale = Vector3(vm_scale, vm_scale, vm_scale)
	holder.add_child(viewmodel)

	var packed: PackedScene = load(data.scene)
	if packed != null:
		var glb := packed.instantiate()
		viewmodel.add_child(glb)
		slide = glb.find_child("Slide", true, false)
		mag = glb.find_child("Magazine", true, false)
		trigger = glb.find_child("Trigger", true, false)
		hand_l = glb.find_child("HandL", true, false)

	muzzle = Node3D.new()
	muzzle.position = Vector3(0, 0.108, -0.1025)
	viewmodel.add_child(muzzle)
	_build_flash()

	anim = AnimationPlayer.new()
	anim.name = "PistolAnim"
	viewmodel.add_child(anim)
	var lib := AnimationLibrary.new()
	lib.add_animation("fire", _make_fire(false))
	lib.add_animation("fire_last", _make_fire(true))
	lib.add_animation("reload_chambered", _make_reload(false))
	lib.add_animation("reload_empty", _make_reload(true))
	anim.add_animation_library("", lib)
	_update_ammo()

func set_active(value: bool) -> void:
	active = value
	if holder != null:
		holder.visible = value
	set_process(value)
	_trigger_down = false
	if not value and anim != null:
		anim.stop()
	if value:
		_update_ammo()

func refill() -> void:
	ammo_mag = int(data.stats.get("mag", 17))
	ammo_reserve = int(data.stats.get("reserve", 102))
	_reloading = false
	_reload_left = 0.0
	_update_ammo()

func dispose() -> void:
	set_active(false)
	if holder != null:
		holder.queue_free()
		holder = null
	queue_free()

func _build_flash() -> void:
	flash_light = OmniLight3D.new()
	flash_light.light_color = Color(1.0, 0.75, 0.4)
	flash_light.light_energy = 2.5
	flash_light.omni_range = 6.0
	flash_light.visible = false
	muzzle.add_child(flash_light)

	flash_mesh = MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.2, 0.2)
	flash_mesh.mesh = q
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_texture = MatLib.smoke_texture()
	m.albedo_color = Color(1.0, 0.75, 0.35, 1.0)
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	flash_mesh.material_override = m
	flash_mesh.visible = false
	muzzle.add_child(flash_mesh)

func _process(delta: float) -> void:
	if not active:
		return
	_kick = lerpf(_kick, 0.0, delta * 10.0)
	holder.position = _base_pos + Vector3(0, 0, _kick)
	holder.rotation.x = _kick * 2.0
	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			flash_light.visible = false
			flash_mesh.visible = false

	if player == null or not player.can_control or player.is_dead:
		return

	if _reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()

	if Input.is_physical_key_pressed(KEY_R) and not _reloading:
		start_reload()

	var pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if pressed and (not _trigger_down or _is_auto()):
		try_fire()
	_trigger_down = pressed

func _is_auto() -> bool:
	return bool(data.stats.get("auto", false))

func try_fire() -> void:
	if _reloading or Time.get_ticks_msec() < _next_fire:
		return
	if ammo_mag <= 0:
		_next_fire = Time.get_ticks_msec() + 250
		if ammo_reserve > 0:
			start_reload()
		return

	ammo_mag -= 1
	var last := ammo_mag == 0
	var rpm := float(data.stats.get("rpm", 420.0))
	_next_fire = Time.get_ticks_msec() + int(60000.0 / maxf(rpm, 1.0))
	_kick = 0.03
	_flash = 0.05
	flash_light.visible = true
	flash_mesh.visible = true
	flash_mesh.rotation.z = randf() * TAU
	player.add_recoil(float(data.stats.get("recoil", 1.5)), randf_range(-0.3, 0.3))
	Sfx.play(String(data.audio.get("fire", "gun_pistol")), -1.5, randf_range(0.97, 1.03), 0.02)
	if anim != null:
		anim.stop()
		anim.play("fire_last" if last else "fire")

	var spread := float(data.stats.get("spread", 0.01))
	var from := camera.global_position
	var base_dir := -camera.global_transform.basis.z

	if data.type == "projectile":
		var pdir := base_dir
		pdir += camera.global_transform.basis.x * randf_range(-spread, spread)
		pdir += camera.global_transform.basis.y * randf_range(-spread, spread)
		_fire_projectile(from, pdir.normalized())
		_update_ammo()
		return

	var pellets := int(data.stats.get("pellets", 1))
	for i in range(pellets):
		var dir := base_dir
		dir += camera.global_transform.basis.x * randf_range(-spread, spread)
		dir += camera.global_transform.basis.y * randf_range(-spread, spread)
		dir = dir.normalized()
		var to := from + dir * float(data.stats.get("range", 120.0))
		var q := PhysicsRayQueryParameters3D.create(from, to, 1 | 4)
		var res: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(q)
		var end := to
		if not res.is_empty():
			end = res.position
			var col = res.collider
			if col is ZombieEnemy:
				var z: ZombieEnemy = col
				var head := z.is_head_hit(res.position)
				var mult := float(data.stats.get("head_multiplier", 2.0)) if head else 1.0
				z.take_damage(float(data.stats.get("damage", 34.0)) * mult, head, res.position)
				Events.hitmarker.emit()
		_tracer(from, end)
	_update_ammo()

func _fire_projectile(from: Vector3, dir: Vector3) -> void:
	var proj := Projectile.new()
	proj.setup(data, from, dir, player)
	var parent := player.get_parent()
	if parent == null:
		parent = get_tree().current_scene
	parent.add_child(proj)

func start_reload() -> void:
	if _reloading or ammo_mag >= int(data.stats.get("mag", 17)) or ammo_reserve <= 0:
		return
	_reloading = true
	var empty := ammo_mag == 0
	var anim_name := "reload_empty" if empty else "reload_chambered"
	if anim != null:
		anim.stop()
		anim.play(anim_name)
		var a: Animation = anim.get_animation(anim_name)
		_reload_total = a.length if a != null else float(data.stats.get("reload_chambered", 1.55))
	else:
		_reload_total = float(data.stats.get("reload_chambered", 1.55))
	_reload_left = _reload_total
	Sfx.play(String(data.audio.get("reload", "reload")), -6, 1.0, 0.05)

func _finish_reload() -> void:
	var cap := int(data.stats.get("mag", 17))
	var need := cap - ammo_mag
	var take := mini(need, ammo_reserve)
	ammo_mag += take
	ammo_reserve -= take
	_reloading = false
	_update_ammo()

func _update_ammo() -> void:
	Events.ammo_changed.emit(ammo_mag, ammo_reserve, data.name)

func _tracer(from: Vector3, to: Vector3) -> void:
	if from.distance_to(to) < 0.5:
		return
	if _tracer_mesh == null:
		_tracer_mesh = BoxMesh.new()
		_tracer_mesh.size = Vector3(0.01, 0.01, 1.0)
	if _tracer_mat == null:
		_tracer_mat = MatLib.emissive(Color(1.0, 0.82, 0.45), 2.0)
	var dist := from.distance_to(to)
	var mi := MeshInstance3D.new()
	mi.mesh = _tracer_mesh
	mi.material_override = _tracer_mat
	mi.scale = Vector3(1.0, 1.0, dist)
	mi.position = (from + to) * 0.5
	var parent := player.get_parent()
	if parent == null:
		parent = get_tree().current_scene
	parent.add_child(mi)
	mi.look_at(to, Vector3.UP)
	var tw := mi.create_tween()
	tw.tween_interval(0.045)
	tw.tween_callback(mi.queue_free)

# ---------------------------------------------------------------- animações

func _track_pos(a: Animation, node: Node3D, keys: Array) -> void:
	if node == null:
		return
	var t := a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(t, NodePath(str(anim.get_parent().get_path_to(node)) + ":position"))
	a.track_set_interpolation_type(t, Animation.INTERPOLATION_CUBIC)
	for k in keys:
		a.track_insert_key(t, float(k[0]), k[1])

func _track_rot(a: Animation, node: Node3D, keys: Array) -> void:
	if node == null:
		return
	var t := a.add_track(Animation.TYPE_VALUE)
	a.track_set_path(t, NodePath(str(anim.get_parent().get_path_to(node)) + ":rotation"))
	a.track_set_interpolation_type(t, Animation.INTERPOLATION_CUBIC)
	for k in keys:
		a.track_insert_key(t, float(k[0]), k[1])

func _make_fire(last: bool) -> Animation:
	var a := Animation.new()
	a.length = 0.14 if last else 0.12
	if slide != null:
		var s := slide.position
		if last:
			_track_pos(a, slide, [[0.0, s], [0.035, s + Vector3(0, 0, 0.024)], [0.14, s + Vector3(0, 0, 0.024)]])
		else:
			_track_pos(a, slide, [[0.0, s], [0.03, s + Vector3(0, 0, 0.024)], [0.095, s]])
	if trigger != null:
		var r := trigger.rotation
		_track_rot(a, trigger, [[0.0, r], [0.025, r + Vector3(0.2, 0, 0)], [0.08, r]])
	return a

func _make_reload(empty: bool) -> Animation:
	var a := Animation.new()
	a.length = 2.05 if empty else 1.55
	var hl := hand_l.position if hand_l != null else Vector3.ZERO
	var hr := hand_l.rotation if hand_l != null else Vector3.ZERO
	var mp := mag.position if mag != null else Vector3.ZERO
	var sp := slide.position if slide != null else Vector3.ZERO

	if empty:
		_track_pos(a, slide, [[0.0, sp + Vector3(0, 0, 0.024)], [1.12, sp + Vector3(0, 0, 0.024)], [1.42, sp]])
		_track_pos(a, hand_l, [
			[0.0, hl],
			[0.18, hl + Vector3(0.02, -0.05, -0.07)],
			[0.52, hl + Vector3(0.02, -0.05, -0.07)],
			[0.82, hl + Vector3(0.01, -0.02, -0.02)],
			[1.02, hl + Vector3(0.02, 0.10, -0.03)],
			[1.22, hl + Vector3(0.02, 0.10, 0.01)],
			[1.42, hl + Vector3(0.02, 0.10, -0.03)],
			[1.75, hl],
		])
		_track_rot(a, hand_l, [[0.0, hr], [0.90, hr], [1.02, hr + Vector3(-0.45, 0, 0)], [1.60, hr]])
	else:
		_track_pos(a, hand_l, [
			[0.0, hl],
			[0.16, hl + Vector3(0.02, -0.05, -0.07)],
			[0.50, hl + Vector3(0.02, -0.05, -0.07)],
			[0.80, hl + Vector3(0.01, -0.02, -0.02)],
			[1.25, hl],
		])
	if mag != null:
		var drop := mp + Vector3(0, -0.145, 0.03)
		if empty:
			_track_pos(a, mag, [[0.0, mp], [0.28, mp], [0.52, drop], [0.68, drop], [1.02, mp]])
		else:
			_track_pos(a, mag, [[0.0, mp], [0.25, mp], [0.48, drop], [0.62, drop], [0.95, mp]])
	return a
