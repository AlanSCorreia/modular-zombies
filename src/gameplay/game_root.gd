class_name GameRoot
extends Node3D

var map: MapData
var weapon_data: WeaponData
var enemy_data: EnemyData
var player: PlayerController
var hud: SliceHUD
var ctx: Dictionary
var nav: MapNav
var zombies: Array[ZombieEnemy] = []
var points := 0
var started := false
var door_open := false
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

	hud = SliceHUD.new()
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

	if "--test" in args:
		_run_test.call_deferred()
	elif "--smoke" in args:
		_run_smoke.call_deferred()
	elif "--pause-test" in args:
		_run_pause_test.call_deferred()
	elif "--pause-shot" in args:
		_run_pause_shot.call_deferred()
	elif "--mouse-test" in args:
		_run_mouse_test.call_deferred()
	elif "--interaction-test" in args:
		_run_interaction_test.call_deferred()
	elif "--slots-test" in args:
		_run_slots_test.call_deferred()
	elif "--softlock-test" in args:
		_run_softlock_test.call_deferred()
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
	elif id == "box":
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
	var info: Dictionary = ctx.doors.get(id, {})
	if info.is_empty() or bool(info.get("open", false)):
		return
	var d: DoorData = info.data
	if not _can_pay(d.cost):
		return
	_spend(d.cost)
	info["open"] = true
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
	Events.banner.emit("SETOR %s ABERTO" % d.room, "", 1.5)

func _buy_wallbuy(id: String) -> void:
	var info: Dictionary = ctx.wallbuys.get(id, {})
	if info.is_empty():
		return
	var wb: WallBuyData = info.data
	var w: WeaponData = Content.get_weapon(wb.weapon_id)
	if w == null:
		Events.banner.emit("ARMA INDISPONÍVEL", wb.name, 1.5)
		return
	if not _can_pay(wb.cost):
		return
	_spend(wb.cost)
	player.add_weapon(w)
	Events.banner.emit(w.name, "COMPRADO", 1.5)

func _buy_perk(id: String) -> void:
	var info: Dictionary = ctx.perks.get(id, {})
	if info.is_empty():
		return
	var p: PerkData = info.data
	if owned_perks.has(id):
		Events.banner.emit(p.name, "JÁ ADQUIRIDO", 1.2)
		return
	if not _can_pay(p.cost):
		return
	_spend(p.cost)
	owned_perks.append(id)
	Events.banner.emit(p.name, "ADQUIRIDO", 1.5)

func _buy_box() -> void:
	if ctx.box.is_empty():
		return
	var cost := int(ctx.box.data.cost)
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

func _run_pause_test() -> void:
	_start()
	await get_tree().create_timer(0.2).timeout
	var filters_ok := hud.mouse_filters_ok()
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().create_timer(0.1).timeout
	var paused_ok: bool = get_tree().paused and hud.is_pause_visible()
	var esc2 := InputEventKey.new()
	esc2.keycode = KEY_ESCAPE
	esc2.pressed = true
	Input.parse_input_event(esc2)
	await get_tree().create_timer(0.1).timeout
	var resumed_ok: bool = not get_tree().paused and not hud.is_pause_visible()
	var ok: bool = filters_ok and paused_ok and resumed_ok
	print("PAUSE_TEST filters=%s paused=%s resumed=%s" % [str(filters_ok), str(paused_ok), str(resumed_ok)])
	print("PAUSE_OK" if ok else "PAUSE_FAIL")
	get_tree().quit(0 if ok else 1)

func _run_mouse_test() -> void:
	_start()
	await get_tree().create_timer(0.2).timeout
	if DisplayServer.get_name() == "headless":
		print("MOUSE_SKIP headless")
		get_tree().quit(0)
		return
	var before := player.rotation.y
	var ev := InputEventMouseMotion.new()
	ev.relative = Vector2(160, 0)
	Input.parse_input_event(ev)
	await get_tree().create_timer(0.2).timeout
	var after := player.rotation.y
	var ok: bool = absf(after - before) > 0.0001
	print("MOUSE_TEST mode=%d before=%.4f after=%.4f ok=%s" % [Input.mouse_mode, before, after, str(ok)])
	print("MOUSE_OK" if ok else "MOUSE_FAIL")
	get_tree().quit(0 if ok else 1)

func _run_interaction_test() -> void:
	_start()
	await get_tree().create_timer(0.2).timeout
	player.position = Vector3(-1.6, 0.1, 0.0)
	player.look_at(Vector3(0.0, player.position.y, 0.0), Vector3.UP)
	player.interact_ray.force_raycast_update()
	var hit := player.interact_ray.is_colliding()
	var meta_ok := false
	if hit:
		var col = player.interact_ray.get_collider()
		meta_ok = col != null and col.has_meta("interact")
	var press := InputEventKey.new()
	press.keycode = KEY_F
	press.physical_keycode = KEY_F
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().create_timer(0.2).timeout
	var release := InputEventKey.new()
	release.keycode = KEY_F
	release.physical_keycode = KEY_F
	release.pressed = false
	Input.parse_input_event(release)
	var ok: bool = hit and meta_ok and door_open
	print("INTERACT_TEST hit=%s meta=%s door=%s" % [str(hit), str(meta_ok), str(door_open)])
	print("INTERACT_OK" if ok else "INTERACT_FAIL")
	get_tree().quit(0 if ok else 1)

func _spawn_pos_in_room(room: String) -> Vector3:
	for s in map.zombie_spawns:
		if s.room == room:
			return s.position
	return map.player_spawn

func _run_softlock_test() -> void:
	_start()
	await get_tree().create_timer(0.2).timeout
	player.health = 100000.0
	var initial_count := zombies.size()
	var only_a := true
	for z in zombies:
		if nav.room_at(z.global_position) != "A":
			only_a = false
	var closed_blocked := nav.path(_spawn_pos_in_room("B"), map.player_spawn).is_empty()

	var guard := 0
	while spawned < map.zombie_count and guard < 20:
		for z in zombies.duplicate():
			z.take_damage(100000.0, false, z.global_position)
		await get_tree().create_timer(0.8).timeout
		guard += 1
	for z in zombies.duplicate():
		z.take_damage(100000.0, false, z.global_position)
	await get_tree().create_timer(0.8).timeout

	var all_spawned := spawned >= map.zombie_count
	var complete_ok := _complete
	var points_before := points
	var points_ok := points_before >= 750
	_buy_door("door1")
	var open_path := nav.path(_spawn_pos_in_room("B"), map.player_spawn)
	var open_ok := not open_path.is_empty()
	var ok: bool = initial_count == 3 and only_a and closed_blocked \
		and all_spawned and complete_ok and points_ok and open_ok
	print("SOFTLOCK_TEST initial=%d only_a=%s closed_blocked=%s spawned=%d points_before=%d complete=%s open_path=%s" % [
		initial_count, str(only_a), str(closed_blocked), spawned, points_before,
		str(complete_ok), str(open_ok),
	])
	print("SOFTLOCK_OK" if ok else "SOFTLOCK_FAIL")
	get_tree().quit(0 if ok else 1)

func _run_slots_test() -> void:
	_start()
	await get_tree().create_timer(0.2).timeout
	var mp5: WeaponData = Content.get_weapon("weapon.mp5")
	player.weapon.ammo_mag = 5
	player.add_weapon(mp5)
	var count_after_add := player.count_weapons()
	var active_mp5: bool = player.weapon != null and player.weapon.data.id == "weapon.mp5"
	player.switch_slot(0)
	var back_glock: bool = player.weapon != null and player.weapon.data.id == "weapon.glock17" and player.weapon.ammo_mag == 5
	player.switch_slot(1)
	var back_mp5: bool = player.weapon != null and player.weapon.data.id == "weapon.mp5"
	player.add_weapon(mp5)
	var no_duplicate := player.count_weapons() == 2
	var ok: bool = count_after_add == 2 and active_mp5 and back_glock and back_mp5 and no_duplicate
	print("SLOTS_TEST count=%d active_mp5=%s glock_ammo=%s mp5=%s no_dup=%s" % [
		count_after_add, str(active_mp5), str(back_glock), str(back_mp5), str(no_duplicate),
	])
	print("SLOTS_OK" if ok else "SLOTS_FAIL")
	get_tree().quit(0 if ok else 1)

func _run_pause_shot() -> void:
	_start()
	await get_tree().create_timer(0.5).timeout
	hud.pause_toggled.emit()
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/opencode/pause_bunker13.png")
	get_tree().quit(0)

func _run_smoke() -> void:
	_start()
	points = 20000
	Events.points_changed.emit(points)
	await get_tree().create_timer(0.3).timeout
	var ok: bool = player != null and not zombies.is_empty() and not ctx.doors.is_empty()
	var door_ok := false
	var wallbuy_ok := false
	var perk_ok := false
	var box_ok := false

	if not ctx.doors.is_empty():
		var door_id := String(ctx.doors.keys()[0])
		var before := points
		_on_interacted(door_id, player)
		door_ok = points < before and bool(ctx.doors[door_id].get("open", false))
		ok = ok and door_ok

	if not ctx.wallbuys.is_empty():
		var wallbuy_id := String(ctx.wallbuys.keys()[0])
		var before := points
		_on_interacted(wallbuy_id, player)
		var wb: WallBuyData = ctx.wallbuys[wallbuy_id].data
		wallbuy_ok = points < before and player.weapon != null and player.weapon.data.id == wb.weapon_id
		ok = ok and wallbuy_ok

	if not ctx.perks.is_empty():
		var perk_id := String(ctx.perks.keys()[0])
		var before := points
		_on_interacted(perk_id, player)
		perk_ok = points < before and owned_perks.has(perk_id)
		ok = ok and perk_ok

	if not ctx.box.is_empty():
		var before := points
		_on_interacted("box", player)
		box_ok = points < before
		ok = ok and box_ok

	print("MAP_SMOKE map=%s zombies=%d doors=%d wallbuys=%d perks=%d box=%s door=%s wallbuy=%s perk=%s box_buy=%s" % [
		map.id, zombies.size(), ctx.doors.size(), ctx.wallbuys.size(),
		ctx.perks.size(), str(not ctx.box.is_empty()),
		str(door_ok), str(wallbuy_ok), str(perk_ok), str(box_ok),
	])
	print("MAP_OK" if ok else "MAP_FAIL")
	get_tree().quit(0 if ok else 1)

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
	var draw := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	print("BENCH fps=%.1f process_ms=%.2f draw_calls=%d memory_mb=%.1f" % [fps, proc, int(draw), mem])
	get_tree().quit(0)
