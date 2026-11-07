class_name GameRoot
extends Node3D

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var map: MapData
var weapon_data: WeaponData
var enemy_data: EnemyData
var player: PlayerController
var hud: SliceHUD
var ctx: MapContext
var nav: MapNav
var zombies: Array[ZombieEnemy] = []
var points := 0
var started := false
var spawned := 0
var owned_perks: Array[String] = []
var _complete := false
var _wave_pending := false

func _ready() -> void:
	randomize()
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	get_viewport().scaling_3d_scale = 0.75
	_setup_environment()

	var args := OS.get_cmdline_user_args()
	var map_id := MapArgs.map_id_from_args(args)
	map = Content.get_map(map_id)
	weapon_data = Content.get_weapon("weapon.glock17")
	enemy_data = Content.get_enemy(map.enemy_id) if map != null else null
	if map == null or weapon_data == null or enemy_data == null:
		push_error("Conteúdo incompleto para o mapa '%s'" % map_id)
		return

	var builder := MapBuilderRegistry.create(map.builder)
	if builder == null:
		push_error("Builder inválido para o mapa %s: %s" % [map.id, map.builder])
		return
	ctx = builder.build(self, map)
	nav = MapNav.new()
	nav.setup(map, ctx.doors)

	player = PlayerController.new()
	player.name = "Player"
	player.position = map.player_spawn
	add_child(player)

	hud = HUD_SCENE.instantiate() as SliceHUD
	hud.name = "HUD"
	add_child(hud)
	hud.set_map_name(map.name)
	hud.start_requested.connect(_start)
	hud.restart_requested.connect(_restart)
	hud.pause_toggled.connect(_on_pause_toggled)
	hud.resume_requested.connect(_resume)

	player.setup_weapon(weapon_data)

	points = map.starting_points
	Events.points_changed.emit(points)
	Events.player_health_changed.emit(player.health, player.max_health)
	Events.zombie_killed.connect(_on_zombie_killed)
	Events.zombie_hit.connect(_on_zombie_hit)
	Events.interacted.connect(_on_interacted)
	Events.player_died.connect(_on_player_died)
	hud.show_start()


func _setup_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.004, 0.007, 0.016)
	sm.sky_horizon_color = Color(0.015, 0.022, 0.035)
	sm.ground_bottom_color = Color(0.005, 0.006, 0.007)
	sm.ground_horizon_color = Color(0.02, 0.022, 0.025)
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.42, 0.47, 0.60)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.25
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.fog_enabled = true
	env.fog_light_color = Color(0.028, 0.036, 0.045)
	env.fog_density = 0.0028
	env.ssao_enabled = false
	env.volumetric_fog_enabled = false
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 0.72
	we.environment = env
	add_child(we)

	var moon := DirectionalLight3D.new()
	moon.light_color = Color(0.42, 0.55, 0.82)
	moon.light_energy = 0.3
	moon.rotation_degrees = Vector3(-58, -32, 0)
	moon.shadow_enabled = true
	add_child(moon)

func _start() -> void:
	if started:
		return
	started = true
	get_tree().paused = false
	hud.hide_pause()
	hud.hide_start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.can_control = true
	_spawn_wave()
	Events.banner.emit(map.name.to_upper(), "SOBREVIVA E ABRA AS PORTAS", 2.5)

func _on_pause_toggled() -> void:
	if not started or player == null or player.is_dead:
		return
	if get_tree().paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	if _complete or player == null or player.is_dead:
		return
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_pause()

func _resume() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.hide_pause()

func _reachable_spawns() -> Array[SpawnData]:
	if nav == null:
		return map.zombie_spawns.duplicate()
	var rooms := nav.reachable_rooms()
	var out: Array[SpawnData] = []
	for s in map.zombie_spawns:
		if rooms.has(s.room):
			out.append(s)
	if out.is_empty():
		return map.zombie_spawns.duplicate()
	return out

func _spawn_wave() -> void:
	_wave_pending = false
	if map == null or enemy_data == null or player == null or player.is_dead:
		return
	var pending := map.zombie_count - spawned
	if pending <= 0:
		return
	var available := _reachable_spawns()
	if available.is_empty():
		return
	var total := mini(pending, mini(3, available.size()))
	var base := spawned
	for i in range(total):
		var s: SpawnData = available[(base + i) % available.size()]
		_spawn_at(s.position)

func _spawn_at(pos: Vector3) -> void:
	var z := ZombieEnemy.new()
	z.setup(enemy_data, player, nav)
	z.position = pos
	add_child(z)
	zombies.append(z)
	spawned += 1

func _on_zombie_killed(z: ZombieEnemy, headshot: bool) -> void:
	zombies.erase(z)
	points += 100 if headshot else 50
	Events.points_changed.emit(points)
	Events.banner.emit("ZUMBI ELIMINADO", "+%d PONTOS" % (100 if headshot else 50), 1.2)
	if zombies.is_empty():
		if spawned < map.zombie_count:
			if not _wave_pending:
				_wave_pending = true
				get_tree().create_timer(0.6, false).timeout.connect(_spawn_wave)
		elif not _complete:
			_complete = true
			Events.banner.emit("ÁREA LIMPA", "PRESSIONE R PARA REINICIAR", 5.0)

func _on_zombie_hit(_z: ZombieEnemy, _damage: float, _head: bool, _pos: Vector3) -> void:
	points += 10
	Events.points_changed.emit(points)

func _on_interacted(id: String, _who: Node) -> void:
	if ctx.doors.has(id):
		_buy_door(id)
	elif ctx.wallbuys.has(id):
		_buy_wallbuy(id)
	elif ctx.perks.has(id):
		_buy_perk(id)
	elif ctx.box != null and id == ctx.box.id:
		_buy_box()

func _can_pay(cost: int) -> bool:
	if points >= cost:
		return true
	Events.banner.emit("PONTOS INSUFICIENTES", "FALTAM %d" % (cost - points), 1.6)
	return false

func _spend(cost: int) -> void:
	points -= cost
	Events.points_changed.emit(points)

func _buy_door(id: String) -> void:
	var door: DoorState = ctx.doors.get(id, null)
	if door == null or door.open:
		return
	if not _can_pay(door.cost):
		return
	_spend(door.cost)
	door.open = true
	var node: Node3D = door.node
	var body: Node = door.body
	if body != null:
		body.queue_free()
	var label: Node = door.label
	if label != null:
		label.queue_free()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "position:y", node.position.y + 2.8, 0.7)
	Events.banner.emit("SETOR %s ABERTO" % door.room, "", 1.5)

func _buy_wallbuy(id: String) -> void:
	var item: Interactable = ctx.wallbuys.get(id, null)
	if item == null:
		return
	var w: WeaponData = Content.get_weapon(item.weapon_id)
	if w == null:
		Events.banner.emit("ARMA INDISPONÍVEL", item.name, 1.5)
		return
	if not _can_pay(item.cost):
		return
	_spend(item.cost)
	player.add_weapon(w)
	Events.banner.emit(w.name, "COMPRADO", 1.5)

func _buy_perk(id: String) -> void:
	var item: Interactable = ctx.perks.get(id, null)
	if item == null:
		return
	if owned_perks.has(id):
		Events.banner.emit(item.name, "JÁ ADQUIRIDO", 1.2)
		return
	if not _can_pay(item.cost):
		return
	_spend(item.cost)
	owned_perks.append(id)
	Events.banner.emit(item.name, "ADQUIRIDO", 1.5)

func _buy_box() -> void:
	if ctx.box == null:
		return
	var cost := ctx.box.cost
	if not _can_pay(cost):
		return
	_spend(cost)
	var ids: Array = Content.weapons.keys()
	if ids.is_empty():
		return
	var w: WeaponData = Content.get_weapon(String(ids[randi() % ids.size()]))
	if w == null:
		return
	player.add_weapon(w)
	Events.banner.emit("CAIXA MISTERIOSA", w.name, 2.0)

func _on_player_died() -> void:
	get_tree().paused = false
	hud.hide_pause()
	hud.show_gameover()

func _restart() -> void:
	get_tree().paused = false
	hud.hide_pause()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if _complete and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_restart()
