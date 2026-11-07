class_name ZombieEnemy
extends CharacterBody3D

static var _scene_cache: Dictionary = {}
static var _stripped: Dictionary = {}

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
var _anim_map: Dictionary = {}
var _anim_state := ""

var _attack_cd := 0.0
var _growl_cd := 3.0
var _override := false
var _scale := 0.4

const BAR_APPROACH := 0
const BAR_TEAR := 1
const BAR_CLIMB := 2
const BAR_INSIDE := 3

var barricade: BarricadeState
var barricade_system: BarricadeSystem
var bar_state := BAR_APPROACH
var round_number := 1

var _approach_pos := Vector3.ZERO
var _inside_pos := Vector3.ZERO
var _outward := Vector3.FORWARD
var _tear_cd := 0.0
var _climb_t := 0.0
var _climb_from := Vector3.ZERO
var _climb_to := Vector3.ZERO

func setup(p_data: EnemyData, p_target: PlayerController, p_nav: MapNav = null) -> void:
	data = p_data
	target = p_target
	nav = p_nav
	health = data.health
	speed = data.speed
	damage = data.damage
	_scale = data.scale

## Associa o zumbi a uma janela: aproxima, arranca tábuas, sobe e entra.
func setup_barricade(p_barricade: BarricadeState, p_system: BarricadeSystem,
		p_round := 1) -> void:
	barricade = p_barricade
	barricade_system = p_system
	round_number = p_round
	bar_state = BAR_APPROACH
	if barricade == null or barricade.data == null or barricade.node == null:
		return
	_outward = barricade.data.spawn_position - barricade.node.global_position
	_outward.y = 0.0
	_outward = _outward.normalized() if _outward.length() > 0.01 else Vector3.FORWARD
	var base := Vector3(
		barricade.node.global_position.x, global_position.y,
		barricade.node.global_position.z
	)
	_approach_pos = base + _outward * 1.05
	_inside_pos = base - _outward * 1.15
	_inside_pos.y = barricade.data.spawn_position.y

var speed := 1.35
var damage := 20.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	floor_snap_length = 0.3
	add_to_group("zombies")

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
	var packed: PackedScene = _scene_cache.get(data.scene, null)
	if packed == null:
		packed = load(data.scene)
		if packed == null:
			return
		_scene_cache[data.scene] = packed
	model = packed.instantiate()
	model.scale = Vector3.ONE * _scale
	add_child(model)
	anim = model.find_child("AnimationPlayer", true, false)
	if anim != null:
		_build_anim_map()
		if not _stripped.has(data.scene):
			_strip_root_motion()
			_stripped[data.scene] = true
		_play("Walk")

func _build_anim_map() -> void:
	_anim_map.clear()
	for a in anim.get_animation_list():
		_anim_map[a] = a
		var idx := a.rfind("|")
		if idx >= 0:
			_anim_map[a.substr(idx + 1)] = a

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

func _play(nm: String) -> void:
	if anim == null or nm == _anim_state:
		return
	var actual: String = _anim_map.get(nm, "")
	_anim_state = nm
	if actual == "":
		return
	anim.play(actual)

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

	if barricade != null and bar_state != BAR_INSIDE:
		_process_barricade(delta)
		return

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

	_move_to(move_target, delta)

	var to_player := target.global_position - global_position
	to_player.y = 0.0
	var can_reach := nav == null or not _path.is_empty()
	if can_reach and to_player.length() < float(data.attack_range) and _attack_cd <= 0.0:
		_attack()

func _move_to(point: Vector3, delta: float, keep_height := false) -> void:
	var flat := point - global_position
	flat.y = 0.0
	var dir := flat.normalized() if flat.length() > 0.01 else Vector3.ZERO
	var desired := dir * speed
	velocity.x = lerpf(velocity.x, desired.x, clampf(5.0 * delta, 0.0, 1.0))
	velocity.z = lerpf(velocity.z, desired.z, clampf(5.0 * delta, 0.0, 1.0))
	if keep_height:
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()

	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * 6.0)
	if anim != null and not _override:
		_play("Walk")
		anim.speed_scale = clampf(speed / 1.5, 0.6, 1.8)

func _process_barricade(delta: float) -> void:
	if barricade == null or barricade.data == null:
		bar_state = BAR_INSIDE
		return
	var breached := barricade.plank_count <= 0

	match bar_state:
		BAR_APPROACH:
			var flat := _approach_pos - global_position
			flat.y = 0.0
			if flat.length() <= 0.55:
				velocity.x = 0.0
				velocity.z = 0.0
				if barricade_system == null \
					or barricade_system.try_claim_tearer(barricade, self):
					if breached:
						_start_climb()
					else:
						bar_state = BAR_TEAR
						_tear_cd = _tear_time()
				else:
					_move_to(_wait_position(), delta, true)
			else:
				_move_to(_approach_pos, delta, true)

		BAR_TEAR:
			velocity.x = 0.0
			velocity.z = 0.0
			if breached:
				_start_climb()
				return
			_tear_cd -= delta
			if _tear_cd <= 0.0:
				_tear_cd = _tear_time()
				barricade_system.tear_plank(barricade)
				_override = true
				_play("Attack")
				if anim != null:
					anim.speed_scale = 1.35
				var t := get_tree().create_timer(0.45)
				t.timeout.connect(func(): _override = false)
				if barricade.plank_count <= 0:
					_start_climb()

		BAR_CLIMB:
			_process_climb(delta)

func _tear_time() -> float:
	var base := barricade.data.tear_time_base
	var scale := barricade.data.tear_time_round_scale
	var round_no := maxf(1.0, float(round_number))
	return maxf(0.15, base / (1.0 + maxf(0.0, round_no - 1.0) * scale))

func _wait_position() -> Vector3:
	var side := _outward.cross(Vector3.UP)
	if side.length() < 0.01:
		side = Vector3.RIGHT
	side = side.normalized()
	var sgn := 1.0 if get_instance_id() % 2 == 0 else -1.0
	return _approach_pos + side * 0.7 * sgn

func _start_climb() -> void:
	if bar_state == BAR_CLIMB:
		return
	bar_state = BAR_CLIMB
	_climb_t = 0.0
	_climb_from = global_position
	_climb_to = _inside_pos
	collision_layer = 0
	collision_mask = 0
	velocity = Vector3.ZERO
	_override = true
	_play("Walk")

func _process_climb(delta: float) -> void:
	var duration := maxf(barricade.data.climb_time, 0.05)
	_climb_t += delta
	var t := clampf(_climb_t / duration, 0.0, 1.0)
	global_position = _climb_from.lerp(_climb_to, t) \
		+ Vector3.UP * sin(t * PI) * 0.9
	if t < 1.0:
		return
	global_position = _climb_to
	bar_state = BAR_INSIDE
	collision_layer = 4
	collision_mask = 1 | 2
	velocity = Vector3.ZERO
	_override = false
	_play("Walk")
	if barricade_system != null:
		barricade_system.release_tearer(barricade, self)

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
	if barricade_system != null and barricade != null:
		barricade_system.release_tearer(barricade, self)
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
