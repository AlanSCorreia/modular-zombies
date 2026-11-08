class_name PlayerController
extends CharacterBody3D

const WALK := 4.2
const SPRINT := 6.3
const JUMP := 4.6
const GRAVITY := 18.0
const MOUSE_SENS := 0.0021
const MAX_SLOTS := 2

var can_control := false
var is_dead := false
var health := 100.0
var max_health := 100.0
var camera: Camera3D
var head: Node3D
var interact_ray: RayCast3D
var weapons: Array[WeaponController] = []
var active_slot := 0
var weapon: WeaponController
var melee: MeleeController
var grenade_data: ExplosiveData
var grenades := 2
var max_grenades := 2
var current_interactable: Interactable = null

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
	add_weapon(data)

func setup_melee(data: MeleeData) -> void:
	if data == null:
		return
	melee = MeleeController.new()
	melee.name = "Melee"
	melee.setup(data, camera, self)
	add_child(melee)

func setup_grenades(data: ExplosiveData, count := 2) -> void:
	grenade_data = data
	max_grenades = count
	grenades = count
	Events.grenades_changed.emit(grenades)

func throw_grenade() -> bool:
	if grenade_data == null or not can_control or is_dead or grenades <= 0 or camera == null:
		return false
	grenades -= 1
	Events.grenades_changed.emit(grenades)
	Events.banner.emit("GRANADA", "%d RESTANTES" % grenades, 0.9)
	Sfx.play("grenade_throw", -4, 1.05, 0.05)
	var from := camera.global_position
	var dir := -camera.global_transform.basis.z
	var g := Grenade.new()
	g.setup(grenade_data, from, dir)
	var parent := get_parent()
	if parent == null:
		parent = get_tree().current_scene
	parent.add_child(g)
	return true

func equip_weapon(data: WeaponData) -> void:
	add_weapon(data)

func _ensure_slots() -> void:
	while weapons.size() < MAX_SLOTS:
		weapons.append(null)

func add_weapon(data: WeaponData) -> void:
	if data == null:
		return
	_ensure_slots()
	for i in range(weapons.size()):
		var owned := weapons[i]
		if owned != null and owned.data.id == data.id:
			switch_slot(i)
			owned.refill()
			return
	var idx := -1
	for i in range(weapons.size()):
		if weapons[i] == null:
			idx = i
			break
	if idx < 0:
		idx = active_slot
		_free_slot(idx)
	var w := WeaponController.new()
	w.name = "Weapon%d" % (idx + 1)
	w.setup(data, camera, self)
	w.slot_index = idx
	add_child(w)
	weapons[idx] = w
	switch_slot(idx)

func count_weapons() -> int:
	var n := 0
	for w in weapons:
		if w != null:
			n += 1
	return n

func _free_slot(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
	var old := weapons[index]
	weapons[index] = null
	if old != null:
		if old == weapon:
			weapon = null
		old.dispose()

func switch_slot(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS:
		return
	_ensure_slots()
	var target := weapons[index]
	if target == null:
		return
	if weapon != null and weapon != target:
		weapon.set_active(false)
	active_slot = index
	weapon = target
	weapon.set_active(true)
	Events.weapon_changed.emit(weapon.data.id, weapon.data.name)
	Events.slot_changed.emit(index + 1, count_weapons())

func cycle_slot(dir: int) -> void:
	if count_weapons() < 2:
		return
	for step in range(1, MAX_SLOTS + 1):
		var idx := posmod(active_slot + dir * step, MAX_SLOTS)
		if idx < weapons.size() and weapons[idx] != null:
			switch_slot(idx)
			return

func _unhandled_input(event: InputEvent) -> void:
	if not can_control or is_dead:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENS, -1.45, 1.45)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			switch_slot(0)
		elif event.keycode == KEY_2:
			switch_slot(1)
		elif event.keycode == KEY_G:
			throw_grenade()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cycle_slot(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cycle_slot(-1)

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
	current_interactable = null
	if interact_ray.is_colliding():
		var col := interact_ray.get_collider()
		if col != null and col.has_meta("interact"):
			var data := col.get_meta("interact") as Interactable
			if data != null:
				current_interactable = data
				var text := ""
				match data.kind:
					Interactable.Kind.DOOR:
						text = "[F] %s — %d" % [data.name, data.cost]
					Interactable.Kind.WALLBUY, Interactable.Kind.PERK:
						text = "[F] COMPRAR %s — %d" % [data.name, data.cost]
					Interactable.Kind.BOX:
						text = "[F] ABRIR CAIXA — %d" % data.cost
					Interactable.Kind.BARRICADE:
						var b := data as BarricadeState
						if b != null and b.data != null:
							if b.plank_count >= b.data.max_planks:
								text = "BARRICADA COMPLETA — %d/%d" % [
									b.plank_count, b.data.max_planks,
								]
							else:
								text = "[F] REPARAR BARRICADA — %d/%d" % [
									b.plank_count, b.data.max_planks,
								]
				Events.prompt_changed.emit(text, not text.is_empty())
				if not text.is_empty():
					if data.kind != Interactable.Kind.BARRICADE:
						var f := Input.is_physical_key_pressed(KEY_F)
						if f and not _f_down:
							Events.interacted.emit(data.id, self)
						_f_down = f
					else:
						_f_down = Input.is_physical_key_pressed(KEY_F)
					return
	Events.prompt_changed.emit("", false)
	_f_down = Input.is_physical_key_pressed(KEY_F)

func get_interactable() -> Interactable:
	return current_interactable

func is_interact_held() -> bool:
	return Input.is_physical_key_pressed(KEY_F)

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
