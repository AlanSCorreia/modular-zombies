class_name PlayerController
extends CharacterBody3D

const WALK := 4.2
const SPRINT := 6.3
const JUMP := 4.6
const GRAVITY := 18.0
const MOUSE_SENS := 0.0021

var can_control := false
var is_dead := false
var health := 100.0
var max_health := 100.0
var camera: Camera3D
var head: Node3D
var interact_ray: RayCast3D
var weapon: WeaponController

var _pitch := 0.0
var _bob := 0.0
var _f_down := false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 4
	floor_snap_length = 0.3

	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	cs.shape = cap
	cs.position = Vector3(0, 0.9, 0)
	add_child(cs)

	head = Node3D.new()
	head.position = Vector3(0, 1.62, 0)
	add_child(head)

	camera = Camera3D.new()
	camera.fov = 75.0
	camera.near = 0.05
	camera.far = 300.0
	camera.current = true
	head.add_child(camera)

	interact_ray = RayCast3D.new()
	interact_ray.target_position = Vector3(0, 0, -3.2)
	interact_ray.collide_with_areas = true
	interact_ray.collision_mask = 1 | 8
	camera.add_child(interact_ray)

	var fill := OmniLight3D.new()
	fill.light_color = Color(1.0, 0.96, 0.9)
	fill.light_energy = 0.55
	fill.omni_range = 2.4
	fill.position = Vector3(0.25, -0.05, -0.35)
	camera.add_child(fill)

func setup_weapon(data: WeaponData) -> void:
	equip_weapon(data)

func equip_weapon(data: WeaponData) -> void:
	if weapon != null:
		weapon.queue_free()
		weapon = null
	weapon = WeaponController.new()
	weapon.name = "Weapon"
	weapon.setup(data, camera, self)
	add_child(weapon)

func _unhandled_input(event: InputEvent) -> void:
	if not can_control or is_dead:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENS, -1.45, 1.45)

func add_recoil(pitch_deg: float, yaw_deg: float = 0.0) -> void:
	_pitch = clampf(_pitch + deg_to_rad(pitch_deg), -1.45, 1.45)
	rotate_y(deg_to_rad(yaw_deg))

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	var dir := Vector3.ZERO
	if can_control:
		var input := Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		)
		if input.length() > 1.0:
			input = input.normalized()
		dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized() * input.length()

	var speed := SPRINT if (can_control and Input.is_physical_key_pressed(KEY_SHIFT)) else WALK
	var target := dir * speed
	velocity.x = lerpf(velocity.x, target.x, clampf(14.0 * delta, 0.0, 1.0))
	velocity.z = lerpf(velocity.z, target.z, clampf(14.0 * delta, 0.0, 1.0))

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif can_control and Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = JUMP
	move_and_slide()

	if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.5:
		_bob += delta * 8.0
		head.position.y = 1.62 + sin(_bob) * 0.012
	else:
		head.position.y = lerpf(head.position.y, 1.62, delta * 8.0)

	camera.rotation.x = _pitch

func _process(_delta: float) -> void:
	if not can_control or is_dead:
		return
	_update_interaction()

func _update_interaction() -> void:
	if interact_ray.is_colliding():
		var col := interact_ray.get_collider()
		if col != null and col.has_meta("interact"):
			var data: Dictionary = col.get_meta("interact")
			var text := ""
			match String(data.get("kind", "")):
				"door":
					text = "[F] %s — %d" % [data.get("name", "ABRIR"), int(data.get("cost", 0))]
				"wallbuy", "perk":
					text = "[F] COMPRAR %s — %d" % [data.get("name", ""), int(data.get("cost", 0))]
				"box":
					text = "[F] ABRIR CAIXA — %d" % int(data.get("cost", 0))
			Events.prompt_changed.emit(text, not text.is_empty())
			if text != "":
				var f := Input.is_physical_key_pressed(KEY_F)
				if f and not _f_down:
					Events.interacted.emit(String(data.get("id", "")), self)
				_f_down = f
				return
	Events.prompt_changed.emit("", false)
	_f_down = Input.is_physical_key_pressed(KEY_F)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = maxf(0.0, health - amount)
	Events.player_health_changed.emit(health, max_health)
	Events.player_damaged.emit(amount)
	Events.damage_flash.emit()
	if health <= 0.0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	can_control = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Events.player_died.emit()
