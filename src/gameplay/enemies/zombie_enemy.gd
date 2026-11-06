class_name ZombieEnemy
extends CharacterBody3D

var data: EnemyData
var target: PlayerController
var nav: MapNav
var health := 100.0
var is_dead := false
var model: Node3D
var anim: AnimationPlayer
var audio: AudioStreamPlayer3D

var _path: Array[Vector3] = []
var _path_timer := 0.0

var _attack_cd := 0.0
var _growl_cd := 3.0
var _override := false
var _scale := 0.4

func setup(p_data: EnemyData, p_target: PlayerController, p_nav: MapNav = null) -> void:
	data = p_data
	target = p_target
	nav = p_nav
	health = data.health
	speed = data.speed
	damage = data.damage
	_scale = data.scale

var speed := 1.35
var damage := 20.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	floor_snap_length = 0.3

	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.33
	cap.height = 1.72
	cs.shape = cap
	cs.position = Vector3(0, 0.86, 0)
	add_child(cs)

	audio = AudioStreamPlayer3D.new()
	audio.unit_size = 7.0
	audio.max_distance = 40.0
	audio.volume_db = -7.0
	add_child(audio)

	_build_model()

func _build_model() -> void:
	if data == null or data.scene == "":
		return
	var packed: PackedScene = load(data.scene)
	if packed == null:
		return
	model = packed.instantiate()
	model.scale = Vector3.ONE * _scale
	add_child(model)
	anim = model.find_child("AnimationPlayer", true, false)
	if anim != null:
		_strip_root_motion()
		_play("Walk")

func _strip_root_motion() -> void:
	if anim == null:
		return
	for nm in anim.get_animation_list():
		var a: Animation = anim.get_animation(nm)
		if a == null:
			continue
		for i in range(a.get_track_count()):
			if a.track_get_type(i) != Animation.TYPE_POSITION_3D:
				continue
			if not str(a.track_get_path(i)).ends_with("mixamorig_Hips"):
				continue
			var count := a.track_get_key_count(i)
			if count <= 0:
				continue
			var base: Vector3 = a.track_get_key_value(i, 0)
			for k in range(count):
				var v: Vector3 = a.track_get_key_value(i, k)
				v.x = base.x
				v.z = base.z
				a.track_set_key_value(i, k, v)

func _play(name: String) -> void:
	if anim == null:
		return
	for a in anim.get_animation_list():
		if a == name or a.ends_with("|" + name):
			anim.play(a)
			return

func _physics_process(delta: float) -> void:
	if is_dead or target == null or target.is_dead:
		return

	_attack_cd = maxf(0.0, _attack_cd - delta)
	_growl_cd -= delta
	if _growl_cd <= 0.0:
		_growl_cd = randf_range(4.0, 8.0)
		if randf() < 0.5:
			audio.stream = Sfx.get_random("zombie_growl")
			audio.pitch_scale = randf_range(0.8, 1.1)
			audio.play()

	var move_target := target.global_position
	if nav != null:
		_path_timer -= delta
		if _path_timer <= 0.0 or _path.is_empty():
			_path_timer = 0.5
			_path = nav.path(global_position, target.global_position)
		while not _path.is_empty():
			var wp := _path[0]
			if Vector2(wp.x - global_position.x, wp.z - global_position.z).length() >= 0.45:
				break
			_path.pop_front()
		move_target = _path[0] if not _path.is_empty() else global_position

	var flat := move_target - global_position
	flat.y = 0.0
	var dir := flat.normalized() if flat.length() > 0.01 else Vector3.ZERO
	var desired := dir * speed
	velocity.x = lerpf(velocity.x, desired.x, clampf(5.0 * delta, 0.0, 1.0))
	velocity.z = lerpf(velocity.z, desired.z, clampf(5.0 * delta, 0.0, 1.0))
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()

	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 6.0)
	if anim != null and not _override:
		_play("Walk")
		anim.speed_scale = clampf(speed / 1.5, 0.6, 1.8)

	var to_player := target.global_position - global_position
	to_player.y = 0.0
	var can_reach := nav == null or not _path.is_empty()
	if can_reach and to_player.length() < float(data.attack_range) and _attack_cd <= 0.0:
		_attack()

func _attack() -> void:
	_attack_cd = float(data.attack_cooldown)
	_override = true
	_play("Attack")
	if anim != null:
		anim.speed_scale = 1.65
	Sfx.play_3d("zombie_attack", global_position, -4, randf_range(0.75, 0.95))
	var t := get_tree().create_timer(0.72)
	t.timeout.connect(func():
		if is_dead or target == null or target.is_dead:
			return
		if global_position.distance_to(target.global_position) < 2.15:
			target.take_damage(damage)
	)
	var t2 := get_tree().create_timer(1.28)
	t2.timeout.connect(func(): _override = false)

func take_damage(amount: float, head: bool, hit_pos: Vector3) -> void:
	if is_dead:
		return
	health -= amount
	Events.zombie_hit.emit(self, amount, head, hit_pos)
	if health <= 0.0:
		_die(head)
		return
	if anim != null and not _override and randf() < 0.3:
		_play("Hit_reaction")
		_override = true
		var t := get_tree().create_timer(0.4)
		t.timeout.connect(func(): _override = false)

func is_head_hit(hit_pos: Vector3) -> bool:
	return hit_pos.y - global_position.y > float(data.head_height)

func _die(head: bool) -> void:
	if is_dead:
		return
	is_dead = true
	collision_layer = 0
	collision_mask = 0
	velocity = Vector3.ZERO
	_override = true
	_play("Die")
	if anim != null:
		anim.speed_scale = 1.15 if head else 0.95
	Sfx.play_3d("zombie_death", global_position, -3, randf_range(0.8, 0.95))
	Events.zombie_killed.emit(self, head)
	var t := get_tree().create_timer(3.1)
	t.timeout.connect(func():
		var tw := create_tween()
		tw.tween_property(model, "position:y", -1.2, 0.8)
		tw.tween_callback(queue_free)
	)
