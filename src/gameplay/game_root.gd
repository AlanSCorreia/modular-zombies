class_name GameRoot
extends Node3D

var map: MapData
var weapon_data: WeaponData
var enemy_data: EnemyData
var player: PlayerController
var hud: SliceHUD
var ctx: Dictionary
var zombies: Array[ZombieEnemy] = []
var points := 0
var started := false
var door_open := false
var spawned := 0
var _complete := false

func _ready() -> void:
	randomize()
	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	get_viewport().scaling_3d_scale = 0.75
	_setup_environment()

	map = Content.get_map("map.slice")
	weapon_data = Content.get_weapon("weapon.glock17")
	enemy_data = Content.get_enemy("enemy.zombie")
	if map == null or weapon_data == null or enemy_data == null:
		push_error("Conteúdo do slice incompleto")
		return

	ctx = SliceBuilder.new().build(self, map)

	player = PlayerController.new()
	player.name = "Player"
	player.position = map.player_spawn
	add_child(player)

	hud = SliceHUD.new()
	hud.name = "HUD"
	add_child(hud)
	hud.start_requested.connect(_start)
	hud.restart_requested.connect(_restart)

	player.setup_weapon(weapon_data)

	points = map.starting_points
	Events.points_changed.emit(points)
	Events.player_health_changed.emit(player.health, player.max_health)
	Events.zombie_killed.connect(_on_zombie_killed)
	Events.zombie_hit.connect(_on_zombie_hit)
	Events.interacted.connect(_on_interacted)
	Events.player_died.connect(_on_player_died)
	hud.show_start()

	var args := OS.get_cmdline_user_args()
	if "--test" in args:
		_run_test.call_deferred()
	elif "--shot" in args:
		_run_shot.call_deferred()
	elif "--ui" in args:
		_run_ui.call_deferred()
	elif "--bench" in args:
		_run_bench.call_deferred()

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
	hud.hide_start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.can_control = true
	_spawn("zA")
	Events.banner.emit("SLICE", "MATE O ZUMBI E ABRA A PORTA", 2.5)

func _spawn(spawn_id: String) -> void:
	var spawn: SpawnData = null
	for s in map.zombie_spawns:
		if s.id == spawn_id:
			spawn = s
			break
	if spawn == null:
		return
	var z := ZombieEnemy.new()
	z.setup(enemy_data, player)
	z.position = spawn.position
	add_child(z)
	zombies.append(z)
	spawned += 1

func _on_zombie_killed(z: ZombieEnemy, headshot: bool) -> void:
	zombies.erase(z)
	points += 100 if headshot else 50
	Events.points_changed.emit(points)
	Events.banner.emit("ZUMBI ELIMINADO", "+%d PONTOS" % (100 if headshot else 50), 1.2)
	if door_open and zombies.is_empty() and not _complete:
		_complete = true
		Events.banner.emit("SLICE COMPLETO", "PRESSIONE R PARA REINICIAR", 5.0)

func _on_zombie_hit(_z: ZombieEnemy, _damage: float, _head: bool, _pos: Vector3) -> void:
	points += 10
	Events.points_changed.emit(points)

func _on_interacted(id: String, _who: Node) -> void:
	if id != "door1" or door_open:
		return
	var info: Dictionary = ctx.doors.get(id, {})
	if info.is_empty():
		return
	var d: DoorData = info.data
	if points < d.cost:
		Events.banner.emit("PONTOS INSUFICIENTES", "FALTAM %d" % (d.cost - points), 1.6)
		return
	points -= d.cost
	Events.points_changed.emit(points)
	door_open = true
	var node: Node3D = info.node
	var body: Node = info.body
	if body != null:
		body.queue_free()
	var label: Node = info.get("label", null)
	if label != null:
		label.queue_free()
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "position:y", node.position.y + 2.8, 0.7)
	Events.banner.emit("SETOR B ABERTO", "", 1.5)
	_spawn("zB")

func _on_player_died() -> void:
	hud.show_gameover()

func _restart() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if _complete and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_restart()

func _run_test() -> void:
	_start()
	await get_tree().create_timer(0.4).timeout
	var p0 := points
	var z := zombies[0] if not zombies.is_empty() else null
	var hp0 := z.health if z != null else 0.0
	if z != null:
		z.set_physics_process(false)
	for i in range(4):
		player.weapon.try_fire()
		await get_tree().create_timer(0.18).timeout
		if z == null or z.is_dead:
			break
	var hp1 := z.health if z != null else 0.0
	await get_tree().create_timer(0.3).timeout
	var p1 := points
	_on_interacted("door1", player)
	await get_tree().create_timer(0.3).timeout
	player.weapon.ammo_mag = 0
	player.weapon.ammo_reserve = 102
	player.weapon.start_reload()
	await get_tree().create_timer(2.2).timeout
	var reloaded := player.weapon.ammo_mag == 17
	var ok := p1 > p0 and door_open and not zombies.is_empty() and reloaded and (z == null or z.is_dead or hp1 < hp0)
	print("SLICE_TEST hp0=%.1f hp1=%.1f points_before=%d points_after=%d door=%s zombies=%d reload=%s" % [hp0, hp1, p0, p1, str(door_open), zombies.size(), str(reloaded)])
	print("SLICE_OK" if ok else "SLICE_FAIL")
	get_tree().quit(0 if ok else 1)

func _run_ui() -> void:
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_start.png")
	get_tree().quit(0)

func _run_shot() -> void:
	_start()
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_a.png")
	_on_interacted("door1", player)
	await get_tree().create_timer(0.7).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_b.png")
	get_tree().quit(0)

func _run_bench() -> void:
	_start()
	await get_tree().create_timer(3.0).timeout
	var fps := Engine.get_frames_per_second()
	var proc := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var draw := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	print("BENCH fps=%.1f process_ms=%.2f draw_calls=%d memory_mb=%.1f" % [fps, proc, int(draw), mem])
	get_tree().quit(0)
