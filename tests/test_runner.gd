extends Node

## Runner de integração. Roda como cena principal para ter autoloads
## (Content/Events/Sfx) disponíveis, mas o harness fica fora do GameRoot.

var game: GameRoot

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var case_id := _arg(args, "--case", "slice")
	var packed: PackedScene = load("res://scenes/main.tscn")
	game = packed.instantiate() as GameRoot
	add_child(game)
	await get_tree().process_frame

	match case_id:
		"slice":
			await _slice()
		"smoke":
			await _smoke()
		"softlock":
			await _softlock()
		"pause":
			await _pause()
		"interaction":
			await _interaction()
		"slots":
			await _slots()
		"melee":
			await _melee()
		"projectile":
			await _projectile()
		"explosion":
			await _explosion()
		"grenade":
			await _grenade()
		"rocket":
			await _rocket()
		"barrel":
			await _barrel()
		"barricade":
			await _barricade()
		"zombie_barricade":
			await _zombie_barricade()
		"viewmodel":
			await _viewmodel()
		"knife":
			await _knife()
		"rounds":
			await _rounds()
		"trap":
			await _trap()
		"fx":
			await _fx()
		"audio":
			await _audio()
		"quest":
			await _quest()
		"radio":
			await _radio()
		"power":
			await _power()
		"main_quest":
			await _main_quest()
		"second_map":
			await _second_map()
		"ui":
			await _ui()
		"shot":
			await _shot()
		"bench":
			await _bench()
		"mouse":
			await _mouse()
		"pause_shot":
			await _pause_shot()
		_:
			push_error("caso desconhecido: " + case_id)
			get_tree().quit(2)

func _arg(args: PackedStringArray, key: String, fallback: String) -> String:
	var i := args.find(key)
	if i >= 0 and i + 1 < args.size():
		return args[i + 1]
	return fallback

func _finish(gate: String, ok: bool) -> void:
	print(gate if ok else gate.replace("_OK", "_FAIL"))
	get_tree().quit(0 if ok else 1)

func _spawn_pos(room: String) -> Vector3:
	for s in game.map.zombie_spawns:
		if s.room == room:
			return s.position
	return game.map.player_spawn

func _slice() -> void:
	game._start()
	await get_tree().create_timer(0.4).timeout
	var p0 := game.economy.points
	var z: ZombieEnemy = game.zombies[0] if not game.zombies.is_empty() else null
	var hp0 := z.health if z != null else 0.0
	if z != null:
		z.set_physics_process(false)
	for i in range(4):
		game.player.weapon.try_fire()
		await get_tree().create_timer(0.18).timeout
		if z == null or z.is_dead:
			break
	var hp1 := z.health if z != null else 0.0
	await get_tree().create_timer(0.3).timeout
	var p1 := game.economy.points
	game._on_interacted("door1", game.player)
	await get_tree().create_timer(0.3).timeout
	game.player.weapon.ammo_mag = 0
	game.player.weapon.ammo_reserve = 102
	game.player.weapon.start_reload()
	await get_tree().create_timer(2.2).timeout
	var reloaded := game.player.weapon.ammo_mag == 17
	var door: DoorState = game.ctx.doors.get("door1", null)
	var opened: bool = door != null and door.open
	var ok: bool = p1 > p0 and opened and not game.zombies.is_empty() and reloaded \
		and (z == null or z.is_dead or hp1 < hp0)
	print("SLICE_TEST hp0=%.1f hp1=%.1f points_before=%d points_after=%d door=%s zombies=%d reload=%s" % [
		hp0, hp1, p0, p1, str(opened), game.zombies.size(), str(reloaded),
	])
	_finish("SLICE_OK", ok)

func _smoke() -> void:
	game._start()
	game.economy.set_points(20000)
	await get_tree().create_timer(0.3).timeout
	var ok: bool = game.player != null and not game.zombies.is_empty() and not game.ctx.doors.is_empty()
	var door_ok := false
	var wallbuy_ok := false
	var perk_ok := false
	var box_ok := false

	if not game.ctx.doors.is_empty():
		var door_id := String(game.ctx.doors.keys()[0])
		var before := game.economy.points
		game._on_interacted(door_id, game.player)
		var door: DoorState = game.ctx.doors[door_id]
		door_ok = game.economy.points < before and door.open
		ok = ok and door_ok

	if not game.ctx.wallbuys.is_empty():
		var wallbuy_id := String(game.ctx.wallbuys.keys()[0])
		var before := game.economy.points
		game._on_interacted(wallbuy_id, game.player)
		var item: Interactable = game.ctx.wallbuys[wallbuy_id]
		wallbuy_ok = game.economy.points < before and game.player.weapon != null \
			and game.player.weapon.data.id == item.weapon_id
		ok = ok and wallbuy_ok

	if not game.ctx.perks.is_empty():
		var perk_id := String(game.ctx.perks.keys()[0])
		var before := game.economy.points
		game._on_interacted(perk_id, game.player)
		perk_ok = game.economy.points < before and game.owned_perks.has(perk_id)
		ok = ok and perk_ok

	if game.ctx.box != null:
		var before := game.economy.points
		game._on_interacted("box", game.player)
		box_ok = game.economy.points < before
		ok = ok and box_ok

	print("MAP_SMOKE map=%s zombies=%d doors=%d wallbuys=%d perks=%d box=%s door=%s wallbuy=%s perk=%s box_buy=%s" % [
		game.map.id, game.zombies.size(), game.ctx.doors.size(), game.ctx.wallbuys.size(),
		game.ctx.perks.size(), str(game.ctx.box != null),
		str(door_ok), str(wallbuy_ok), str(perk_ok), str(box_ok),
	])
	_finish("MAP_OK", ok)

func _softlock() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	game.player.health = 100000.0
	var initial_count := game.zombies.size()
	var only_a := true
	for z in game.zombies:
		if z.barricade == null or z.barricade.data.room != "A":
			only_a = false
	var closed_blocked := game.nav.path(_spawn_pos("B"), game.map.player_spawn).is_empty()

	var guard := 0
	while game.round.spawned < game.map.zombie_count and guard < 20:
		for z in game.zombies.duplicate():
			z.take_damage(100000.0, false, z.global_position)
		await get_tree().create_timer(0.8).timeout
		guard += 1
	for z in game.zombies.duplicate():
		z.take_damage(100000.0, false, z.global_position)
	await get_tree().create_timer(0.8).timeout

	var all_spawned := game.round.spawned >= game.map.zombie_count
	var complete_ok := game.round.is_complete()
	var points_before := game.economy.points
	var points_ok := points_before >= 750
	game._buy_door("door1")
	var open_ok := not game.nav.path(_spawn_pos("B"), game.map.player_spawn).is_empty()
	var ok: bool = initial_count == 3 and only_a and closed_blocked \
		and all_spawned and complete_ok and points_ok and open_ok
	print("SOFTLOCK_TEST initial=%d only_a=%s closed_blocked=%s spawned=%d points_before=%d complete=%s open_path=%s" % [
		initial_count, str(only_a), str(closed_blocked), game.round.spawned, points_before,
		str(complete_ok), str(open_ok),
	])
	_finish("SOFTLOCK_OK", ok)

func _pause() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var filters_ok := game.hud.mouse_filters_ok()
	_press_escape()
	await get_tree().create_timer(0.1).timeout
	var paused_ok: bool = get_tree().paused and game.hud.is_pause_visible()
	_press_escape()
	await get_tree().create_timer(0.1).timeout
	var resumed_ok: bool = not get_tree().paused and not game.hud.is_pause_visible()
	var ok: bool = filters_ok and paused_ok and resumed_ok
	print("PAUSE_TEST filters=%s paused=%s resumed=%s" % [str(filters_ok), str(paused_ok), str(resumed_ok)])
	_finish("PAUSE_OK", ok)

func _press_escape() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_ESCAPE
	ev.pressed = true
	Input.parse_input_event(ev)

func _interaction() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	game.player.position = Vector3(-1.6, 0.1, 0.0)
	game.player.look_at(Vector3(0.0, game.player.position.y, 0.0), Vector3.UP)
	game.player.interact_ray.force_raycast_update()
	var hit := game.player.interact_ray.is_colliding()
	var meta_ok := false
	if hit:
		var col = game.player.interact_ray.get_collider()
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
	var door: DoorState = game.ctx.doors.get("door1", null)
	var opened: bool = door != null and door.open
	var ok: bool = hit and meta_ok and opened
	print("INTERACT_TEST hit=%s meta=%s door=%s" % [str(hit), str(meta_ok), str(opened)])
	_finish("INTERACT_OK", ok)

func _slots() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var mp5: WeaponData = Content.get_weapon("weapon.mp5")
	game.player.weapon.ammo_mag = 5
	game.player.add_weapon(mp5)
	var count_after_add := game.player.count_weapons()
	var active_mp5: bool = game.player.weapon != null and game.player.weapon.data.id == "weapon.mp5"
	game.player.switch_slot(0)
	var back_glock: bool = game.player.weapon != null and game.player.weapon.data.id == "weapon.glock17" \
		and game.player.weapon.ammo_mag == 5
	game.player.switch_slot(1)
	var back_mp5: bool = game.player.weapon != null and game.player.weapon.data.id == "weapon.mp5"
	game.player.add_weapon(mp5)
	var no_duplicate := game.player.count_weapons() == 2
	var ok: bool = count_after_add == 2 and active_mp5 and back_glock and back_mp5 and no_duplicate
	print("SLOTS_TEST count=%d active_mp5=%s glock_ammo=%s mp5=%s no_dup=%s" % [
		count_after_add, str(active_mp5), str(back_glock), str(back_mp5), str(no_duplicate),
	])
	_finish("SLOTS_OK", ok)

func _melee() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var z: ZombieEnemy = game.zombies[0]
	z.set_physics_process(false)
	var forward := -game.player.global_transform.basis.z
	z.position = game.player.position + forward * 1.2
	z.position.y = game.player.position.y
	game.player.look_at(Vector3(z.position.x, game.player.position.y, z.position.z), Vector3.UP)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.1).timeout
	var before := z.health
	var hit := game.player.melee != null and game.player.melee.try_swing()
	await get_tree().create_timer(0.1).timeout
	var ok: bool = hit and (z.is_dead or z.health < before)
	print("MELEE_TEST hit=%s before=%.1f after=%.1f dead=%s" % [
		str(hit), before, z.health, str(z.is_dead),
	])
	_finish("MELEE_OK", ok)

func _projectile() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var w: WeaponData = Content.get_weapon("weapon.wunder")
	game.player.add_weapon(w)
	var z: ZombieEnemy = game.zombies[0]
	z.set_physics_process(false)
	var forward := -game.player.global_transform.basis.z
	z.position = game.player.position + forward * 3.0
	z.position.y = game.player.position.y
	game.player.look_at(Vector3(z.position.x, game.player.position.y, z.position.z), Vector3.UP)
	await get_tree().process_frame
	await get_tree().physics_frame
	var before := z.health
	game.player.weapon.try_fire()
	await get_tree().create_timer(0.8).timeout
	var ok: bool = z.is_dead or z.health < before
	print("PROJECTILE_TEST before=%.1f after=%.1f dead=%s weapon=%s" % [
		before, z.health, str(z.is_dead), game.player.weapon.data.id,
	])
	_finish("PROJECTILE_OK", ok)

func _explosion() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var data: ExplosiveData = Content.get_explosive("explosive.frag")
	var center := Vector3(-4.0, 0.1, 0.0)

	var z1 := ZombieEnemy.new()
	z1.setup(game.enemy_data, game.player, game.nav)
	game.add_child(z1)
	var z2 := ZombieEnemy.new()
	z2.setup(game.enemy_data, game.player, game.nav)
	game.add_child(z2)
	var z3 := ZombieEnemy.new()
	z3.setup(game.enemy_data, game.player, game.nav)
	game.add_child(z3)
	z1.set_physics_process(false)
	z2.set_physics_process(false)
	z3.set_physics_process(false)
	z1.position = center + Vector3(1.0, 0.0, 0.0)
	z2.position = center + Vector3(2.5, 0.0, 0.0)
	z3.position = center + Vector3(3.5, 0.0, 0.0)

	var wall := StaticBody3D.new()
	wall.collision_layer = 1
	wall.collision_mask = 0
	wall.position = center + Vector3(2.75, 1.0, 0.0)
	var wmesh := MeshInstance3D.new()
	var wbox := BoxMesh.new()
	wbox.size = Vector3(0.2, 2.0, 3.0)
	wmesh.mesh = wbox
	wall.add_child(wmesh)
	var wcs := CollisionShape3D.new()
	var wshape := BoxShape3D.new()
	wshape.size = Vector3(0.2, 2.0, 3.0)
	wcs.shape = wshape
	wall.add_child(wcs)
	game.add_child(wall)

	var rb := RigidBody3D.new()
	rb.gravity_scale = 0.0
	rb.collision_layer = 16
	rb.collision_mask = 0
	rb.position = center + Vector3(1.5, 1.0, 0.0)
	var rmesh := MeshInstance3D.new()
	var rbox := BoxMesh.new()
	rbox.size = Vector3(0.5, 0.5, 0.5)
	rmesh.mesh = rbox
	rb.add_child(rmesh)
	var rcs := CollisionShape3D.new()
	var rshape := BoxShape3D.new()
	rshape.size = Vector3(0.5, 0.5, 0.5)
	rcs.shape = rshape
	rb.add_child(rcs)
	game.add_child(rb)

	var chain_center := Vector3(-5.0, 0.1, 8.0)
	var b1 := ExplosiveBarrel.new()
	b1.setup(data, chain_center + Vector3(0.0, 0.0, -1.0))
	game.add_child(b1)
	var b2 := ExplosiveBarrel.new()
	b2.setup(data, chain_center + Vector3(-1.0, 0.0, 0.0))
	game.add_child(b2)
	var far := ExplosiveBarrel.new()
	far.setup(data, chain_center + Vector3(0.0, 0.0, 4.5))
	game.add_child(far)

	await get_tree().create_timer(0.15).timeout
	ExplosionSystem.explode(game.get_world_3d(), get_tree(), center, data, 0)
	await get_tree().create_timer(0.15).timeout

	var z1_dmg := 100.0 - z1.health
	var z2_dmg := 100.0 - z2.health
	var falloff_ok := z1_dmg > z2_dmg and z2_dmg > 0.0
	var los_ok := z3.health >= 99.9
	var impulse_ok := rb.linear_velocity.length() > 0.01

	ExplosionSystem.explode(game.get_world_3d(), get_tree(), chain_center, data, 0)
	var chain_ok := b1.detonated and b2.detonated and not far.detonated
	var ok: bool = falloff_ok and los_ok and impulse_ok and chain_ok
	print("EXPLOSION_TEST near=%.1f far=%.1f los=%s impulse=%s chain=%s" % [
		z1_dmg, z2_dmg, str(los_ok), str(impulse_ok), str(chain_ok),
	])
	_finish("EXPLOSION_OK", ok)

func _grenade() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var z: ZombieEnemy = game.zombies[0]
	z.set_physics_process(false)
	var forward := -game.player.global_transform.basis.z
	z.position = game.player.position + forward * 3.0
	z.position.y = game.player.position.y
	game.player.look_at(Vector3(z.position.x, game.player.position.y, z.position.z), Vector3.UP)
	await get_tree().process_frame
	await get_tree().physics_frame
	var count_before := game.player.grenades
	game.player.grenade_data.fuse = 0.6
	var thrown := game.player.throw_grenade()
	await get_tree().create_timer(1.2).timeout
	var ok: bool = thrown and game.player.grenades == count_before - 1 and (z.is_dead or z.health < 100.0)
	print("GRENADE_TEST thrown=%s count=%d dead=%s hp=%.1f" % [
		str(thrown), game.player.grenades, str(z.is_dead), z.health,
	])
	_finish("GRENADE_OK", ok)

func _rocket() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	game.player.add_weapon(Content.get_weapon("weapon.rocket"))
	var z: ZombieEnemy = game.zombies[0]
	z.set_physics_process(false)
	var forward := -game.player.global_transform.basis.z
	z.position = game.player.position + forward * 3.0
	z.position.y = game.player.position.y
	game.player.look_at(Vector3(z.position.x, game.player.position.y, z.position.z), Vector3.UP)
	await get_tree().process_frame
	await get_tree().physics_frame
	game.player.weapon.try_fire()
	await get_tree().create_timer(1.2).timeout
	var ok: bool = z.is_dead or z.health < 100.0
	print("ROCKET_TEST dead=%s hp=%.1f" % [str(z.is_dead), z.health])
	_finish("ROCKET_OK", ok)

func _barrel() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var ids := game.ctx.barrels.keys()
	if ids.size() < 2:
		_finish("BARREL_OK", false)
		return
	var b1: ExplosiveBarrel = game.ctx.barrels[String(ids[0])]
	var b2: ExplosiveBarrel = game.ctx.barrels[String(ids[1])]
	game.player.position = b1.global_position + Vector3(0, 0.1 - b1.global_position.y, -2.0)
	game.player.look_at(Vector3(b1.global_position.x, game.player.position.y, b1.global_position.z), Vector3.UP)
	game.player._pitch = -0.55
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.1).timeout
	game.player.weapon.try_fire()
	var ok: bool = b1.detonated and b2.detonated
	print("BARREL_TEST b1=%s b2=%s" % [str(b1.detonated), str(b2.detonated)])
	_finish("BARREL_OK", ok)

func _barricade() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	if game.ctx.barricades.is_empty() or game.barricade_system == null:
		_finish("BARRICADE_OK", false)
		return

	var bid := String(game.ctx.barricades.keys()[0])
	var b: BarricadeState = game.ctx.barricades[bid]
	var bs := game.barricade_system
	var maxp := b.data.max_planks
	var full_ok: bool = b.plank_count == maxp and _planks_visible(b) == maxp
	var points0 := game.economy.points

	bs.tear_plank(b)
	bs.tear_plank(b)
	var torn: bool = b.plank_count == maxp - 2 and _planks_visible(b) == maxp - 2

	bs.repair_tick(b, b.data.repair_time * 0.5)
	var partial: bool = b.repair_progress > 0.0 and b.plank_count == maxp - 2
	Events.player_damaged.emit(5.0)
	var damage_cancel: bool = is_zero_approx(b.repair_progress) \
		and b.plank_count == maxp - 2
	bs.repair_tick(b, b.data.repair_time * 0.5)
	Events.weapon_changed.emit("weapon.test", "TESTE")
	var weapon_cancel: bool = is_zero_approx(b.repair_progress) \
		and b.plank_count == maxp - 2

	bs.repair_tick(b, b.data.repair_time * 2.05)
	var repaired: bool = b.plank_count == maxp and _planks_visible(b) == maxp
	var paid: bool = game.economy.points == points0 + b.data.repair_points * 2
	var limit_ok: bool = not bs.repair_one(b) and b.plank_count == maxp

	for i in range(maxp):
		bs.tear_plank(b)
	var breach: bool = b.plank_count == 0 and b.breached and _planks_visible(b) == 0
	var floor_ok: bool = not bs.tear_plank(b)
	var ok: bool = full_ok and torn and partial and damage_cancel and weapon_cancel \
		and repaired and paid and limit_ok and breach and floor_ok
	print("BARRICADE_TEST full=%s torn=%s partial=%s cancel=%s weapon=%s repaired=%s paid=%s limit=%s breach=%s" % [
		str(full_ok), str(torn), str(partial), str(damage_cancel),
		str(weapon_cancel), str(repaired), str(paid), str(limit_ok), str(breach),
	])
	_finish("BARRICADE_OK", ok)

func _planks_visible(b: BarricadeState) -> int:
	var n := 0
	for p in b.planks:
		if p.visible:
			n += 1
	return n

func _zombie_barricade() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	game.player.health = 100000.0
	game.round.stop()
	for z in game.zombies.duplicate():
		z.queue_free()
	game.zombies.clear()
	await get_tree().process_frame

	var b: BarricadeState = game.ctx.barricades.get("bar_A1", null)
	if b == null:
		_finish("ZOMBIE_BARRICADE_OK", false)
		return
	b.setup_runtime()
	b.data.tear_time_base = 0.2
	b.data.climb_time = 0.25
	var z1 := _make_barricade_zombie(b)
	var z2 := _make_barricade_zombie(b)

	var approach_ok: bool = z1.bar_state == ZombieEnemy.BAR_APPROACH \
		and z2.bar_state == ZombieEnemy.BAR_APPROACH
	var queue_ok := true
	var saw_tear := false
	var guard := 0
	while guard < 80:
		await get_tree().create_timer(0.1).timeout
		var busy := 0
		for z in [z1, z2]:
			if z.bar_state == ZombieEnemy.BAR_TEAR \
				or z.bar_state == ZombieEnemy.BAR_CLIMB:
				busy += 1
			if z.bar_state == ZombieEnemy.BAR_TEAR:
				saw_tear = true
		if busy > 1:
			queue_ok = false
		if z1.bar_state == ZombieEnemy.BAR_INSIDE \
			and z2.bar_state == ZombieEnemy.BAR_INSIDE:
			break
		guard += 1

	var breached: bool = b.plank_count == 0 and b.breached
	var inside: bool = z1.bar_state == ZombieEnemy.BAR_INSIDE \
		and z2.bar_state == ZombieEnemy.BAR_INSIDE
	var in_room: bool = game.nav.room_at(z1.global_position) == "A" \
		and game.nav.room_at(z2.global_position) == "A"
	var path_ok: bool = not game.nav.path(
		z1.global_position, game.player.global_position
	).is_empty()
	var ok: bool = approach_ok and saw_tear and queue_ok and breached \
		and inside and in_room and path_ok
	print("ZOMBIE_BARRICADE_TEST approach=%s tear=%s queue=%s breach=%s inside=%s room=%s path=%s" % [
		str(approach_ok), str(saw_tear), str(queue_ok), str(breached),
		str(inside), str(in_room), str(path_ok),
	])
	_finish("ZOMBIE_BARRICADE_OK", ok)

func _make_barricade_zombie(b: BarricadeState) -> ZombieEnemy:
	var z := ZombieEnemy.new()
	z.setup(game.enemy_data, game.player, game.nav)
	z.position = b.data.spawn_position + Vector3(0.15, 0.0, 0.0)
	game.add_child(z)
	z.setup_barricade(b, game.barricade_system)
	game.zombies.append(z)
	return z

func _viewmodel() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout

	var shared_ok := true
	var embedded_ok := true
	var sockets_ok := true
	for id in Content.weapons.keys():
		var w: WeaponData = Content.get_weapon(String(id))
		if w.hands != ViewmodelFactory.HANDS_PATH:
			shared_ok = false
		var holder := Node3D.new()
		game.add_child(holder)
		var built := ViewmodelFactory.build(w, holder)
		if built.hands == null or built.hand_l == null or built.hand_r == null:
			shared_ok = false
		holder.queue_free()

		var scene: PackedScene = load(w.scene)
		if scene != null:
			var gun := scene.instantiate()
			if gun.find_child("HandL", true, false) != null \
				or gun.find_child("HandR", true, false) != null:
				embedded_ok = false
			if w.id == "weapon.glock17" or w.id == "weapon.mp5":
				if gun.find_child("GripSocket", true, false) == null \
					or gun.find_child("Muzzle", true, false) == null:
					sockets_ok = false
			gun.free()

	var mp5: WeaponData = Content.get_weapon("weapon.mp5")
	game.player.add_weapon(mp5)
	await get_tree().process_frame
	var wc: WeaponController = game.player.weapon
	var equipped := wc != null and wc.data.id == "weapon.mp5" \
		and wc.hands != null and wc.hand_l != null
	var gripped := equipped and wc.hands.get_parent() != null \
		and String(wc.hands.get_parent().name) == "GripSocket"

	var fired := false
	var reloaded := false
	if wc != null:
		wc.ammo_mag = 3
		wc.try_fire()
		await get_tree().create_timer(0.1).timeout
		fired = wc.ammo_mag == 2
		wc.ammo_mag = 0
		wc.ammo_reserve = 30
		wc.start_reload()
		await get_tree().create_timer(2.6).timeout
		reloaded = wc.ammo_mag > 0

	var ok: bool = shared_ok and embedded_ok and sockets_ok \
		and equipped and gripped and fired and reloaded
	print("VIEWMODEL_TEST shared=%s embedded=%s sockets=%s equipped=%s grip=%s fire=%s reload=%s" % [
		str(shared_ok), str(embedded_ok), str(sockets_ok), str(equipped),
		str(gripped), str(fired), str(reloaded),
	])
	_finish("VIEWMODEL_OK", ok)

func _knife() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var data: MeleeData = Content.get_melee("melee.knife")
	var mc: MeleeController = game.player.melee
	var asset_ok: bool = data != null and data.scene != "" \
		and data.hands == ViewmodelFactory.HANDS_PATH
	var built_ok: bool = mc != null and mc.knife != null \
		and mc.hands != null and mc.hand_r != null
	var attached: bool = built_ok and mc.knife.get_parent() == mc.hand_r
	var left_hidden: bool = mc != null and mc.hand_l != null \
		and not mc.hand_l.visible
	var started_hidden: bool = mc != null and mc.viewmodel != null \
		and not mc.viewmodel.visible
	var swung := false
	if mc != null:
		mc.try_swing()
		swung = mc.viewmodel != null and mc.viewmodel.visible
	await get_tree().create_timer(0.5).timeout
	var hidden_again: bool = mc != null and mc.viewmodel != null \
		and not mc.viewmodel.visible
	var ok: bool = asset_ok and built_ok and attached and left_hidden \
		and started_hidden and swung and hidden_again
	print("KNIFE_TEST asset=%s built=%s attached=%s left_hidden=%s swung=%s hidden=%s" % [
		str(asset_ok), str(built_ok), str(attached), str(left_hidden),
		str(swung), str(hidden_again),
	])
	_finish("KNIFE_OK", ok)

func _rounds() -> void:
	game._start()
	await get_tree().create_timer(0.3).timeout
	var base := game.map.zombie_count
	var round1: bool = game.round.round_no == 1 \
		and game.round.target_count == base
	var label1 := game.hud.round_label_text().contains("RODADA 1")

	var guard := 0
	while not game.round.is_complete() and guard < 40:
		for z in game.zombies.duplicate():
			if not z.is_dead:
				z.take_damage(100000.0, false, z.global_position)
		await get_tree().create_timer(0.35).timeout
		guard += 1
	var complete1: bool = game.round.is_complete() and game.round.round_no == 1

	game.round.next_round()
	await get_tree().create_timer(0.4).timeout
	var round2: bool = game.round.round_no == 2 \
		and game.round.target_count == base + 2
	var label2 := game.hud.round_label_text().contains("RODADA 2")
	var spawned2: bool = game.round.spawned > 0 and not game.zombies.is_empty()

	game.player.take_damage(99999.0)
	await get_tree().create_timer(0.2).timeout
	var over: bool = game.hud.is_gameover_visible() and not game.round.active
	var ok: bool = round1 and label1 and complete1 and round2 \
		and label2 and spawned2 and over
	print("ROUNDS_TEST r1=%s label1=%s complete1=%s r2=%s label2=%s spawn=%s over=%s" % [
		str(round1), str(label1), str(complete1), str(round2),
		str(label2), str(spawned2), str(over),
	])
	_finish("ROUNDS_OK", ok)

func _trap() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	game.round.stop()
	var trap: ExplosiveTrap = game.ctx.traps.get("trap_A1", null)
	if trap == null:
		_finish("TRAP_OK", false)
		return

	var pos := trap.global_position
	var built: bool = trap.data != null and trap.area != null \
		and trap.get_child_count() >= 3
	var z := ZombieEnemy.new()
	z.setup(game.enemy_data, game.player, game.nav)
	z.set_physics_process(false)
	z.position = pos + Vector3(1.0, 0.1, 0.0)
	game.add_child(z)
	await get_tree().create_timer(0.4).timeout

	var detonated: bool = not is_instance_valid(trap)
	if not detonated and is_instance_valid(trap):
		trap.detonate(0)
		await get_tree().create_timer(0.15).timeout
		detonated = true
	var damaged: bool = z.is_dead or z.health < 100.0
	var ok: bool = built and detonated and damaged
	print("TRAP_TEST built=%s detonated=%s hp=%.1f dead=%s" % [
		str(built), str(detonated), z.health, str(z.is_dead),
	])
	_finish("TRAP_OK", ok)

func _fx() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var label2 := game.hud.grenade_label_text().contains("2")
	game.player.throw_grenade()
	await get_tree().create_timer(0.05).timeout
	var label1 := game.hud.grenade_label_text().contains("1")
	var data: ExplosiveData = Content.get_explosive("explosive.frag")
	ExplosionSystem.explode(
		game.get_world_3d(), get_tree(), Vector3(0, 1, 0), data, 0
	)
	await get_tree().create_timer(0.05).timeout
	var has_fx := not get_tree().get_nodes_in_group("explosion_fx").is_empty()
	var sounds := Sfx.has("explosion") and Sfx.has("knife_slash") \
		and Sfx.has("barricade_repair") and Sfx.has("grenade_throw")
	var ok: bool = label2 and label1 and has_fx and sounds
	print("FX_TEST grenade2=%s grenade1=%s fx=%s sounds=%s" % [
		str(label2), str(label1), str(has_fx), str(sounds),
	])
	_finish("FX_OK", ok)

func _audio() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var buses := true
	for bus_name in ["Master", "Music", "Weapons", "Zombies", "UI", "Foley"]:
		if not Sfx.has_bus(bus_name):
			buses = false
	var keys := Sfx.has("round_start") and Sfx.has("round_end") \
		and Sfx.has("explosion") and Sfx.has("zombie_growl")
	var slider := game.hud.volume_slider_value()
	var slider_ok := slider >= 0.0 and slider <= 1.0
	game.hud.get_node("Pause/Center/VBox/VolumeRow/VolumeSlider").value = 0.25
	await get_tree().create_timer(0.05).timeout
	var volume_ok := absf(Sfx.get_master_volume() - 0.25) < 0.05
	Sfx.set_master_volume(0.8)
	var ok: bool = buses and keys and slider_ok and volume_ok
	print("AUDIO_TEST buses=%s keys=%s slider=%.2f volume=%s" % [
		str(buses), str(keys), slider, str(volume_ok),
	])
	_finish("AUDIO_OK", ok)

func _quest() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var qs: QuestSystem = game.quest_system
	var quest: QuestData = Content.get_quest("quest.bunker13_music")
	var loaded: bool = qs != null and quest != null
	if not loaded:
		_finish("QUEST_OK", false)
		return
	var start_index := qs.step_index(quest.id)
	qs.notify_interact("radio_3")
	var skipped: bool = qs.step_index(quest.id) == start_index
	var points0 := game.economy.points
	qs.notify_interact("radio_1")
	qs.notify_interact("radio_2")
	qs.notify_interact("radio_3")
	var done := qs.is_complete(quest.id)
	var points_ok := game.economy.points >= points0 + 500
	var music_ok := Sfx.has("music.bunker13")
	var ok: bool = loaded and skipped and done and points_ok and music_ok
	print("QUEST_TEST loaded=%s skipped=%s done=%s points=%s music=%s" % [
		str(loaded), str(skipped), str(done), str(points_ok), str(music_ok),
	])
	_finish("QUEST_OK", ok)

func _radio() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var ok_radios := game.ctx.radios.size() == 3
	for id in ["radio_1", "radio_2", "radio_3"]:
		var radio: RadioState = game.ctx.radios.get(id, null)
		if radio == null or radio.area == null or not radio.area.has_meta("interact"):
			ok_radios = false
	var quest: QuestData = Content.get_quest("quest.bunker13_music")
	var points0 := game.economy.points
	for id in ["radio_1", "radio_2", "radio_3"]:
		Events.interacted.emit(id, game.player)
	await get_tree().create_timer(0.1).timeout
	var used := true
	for id in ["radio_1", "radio_2", "radio_3"]:
		var radio: RadioState = game.ctx.radios.get(id, null)
		if radio == null or not radio.used:
			used = false
	var done: bool = game.quest_system.is_complete(quest.id)
	var points_ok := game.economy.points >= points0 + 500
	var music_ok := Sfx.has("music.bunker13")
	var ok: bool = ok_radios and used and done and points_ok and music_ok
	print("RADIO_TEST radios=%s used=%s quest=%s points=%s music=%s" % [
		str(ok_radios), str(used), str(done), str(points_ok), str(music_ok),
	])
	_finish("RADIO_OK", ok)

func _power() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var sw: PowerSwitchState = game.ctx.power_switches.get("power_1", null)
	var door: DoorState = game.ctx.doors.get("door2", null)
	if sw == null or door == null or sw.area == null:
		_finish("POWER_OK", false)
		return
	var lights_off := true
	for light in game.ctx.power_lights:
		if light.visible:
			lights_off = false
	var points0 := game.economy.points
	Events.interacted.emit("power_1", game.player)
	await get_tree().create_timer(0.1).timeout
	var lights_on := not game.ctx.power_lights.is_empty()
	for light in game.ctx.power_lights:
		if not light.visible:
			lights_on = false
	var quest: QuestData = Content.get_quest("quest.bunker13_power")
	var done: bool = game.quest_system.is_complete(quest.id)
	var paid := game.economy.points >= points0 + 300
	var points1 := game.economy.points
	Events.interacted.emit("power_1", game.player)
	await get_tree().create_timer(0.05).timeout
	var idempotent := game.economy.points == points1
	var ok: bool = lights_off and sw.used and door.open and lights_on \
		and done and paid and idempotent
	print("POWER_TEST off=%s used=%s door=%s lights=%s quest=%s points=%s idem=%s" % [
		str(lights_off), str(sw.used), str(door.open), str(lights_on),
		str(done), str(paid), str(idempotent),
	])
	_finish("POWER_OK", ok)

func _main_quest() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var q: QuestData = Content.get_quest("quest.bunker13_main")
	if q == null:
		_finish("MAIN_QUEST_OK", false)
		return
	Events.interacted.emit("radio_1", game.player)
	var ordered: bool = game.quest_system.step_index(q.id) == 0
	var points0 := game.economy.points
	Events.interacted.emit("power_1", game.player)
	Events.interacted.emit("radio_1", game.player)
	game.quest_system.notify_enter_area("C")
	await get_tree().create_timer(0.1).timeout
	var done := game.quest_system.is_complete(q.id)
	var paid := game.economy.points >= points0 + 1000
	var ok: bool = ordered and done and paid
	print("MAIN_QUEST_TEST ordered=%s done=%s paid=%s points=%d" % [
		str(ordered), str(done), str(paid), game.economy.points,
	])
	_finish("MAIN_QUEST_OK", ok)

func _second_map() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	var map_ok: bool = game.map.id == "map.depot" and game.ctx.doors.size() == 1 \
		and game.ctx.wallbuys.size() == 1 and game.ctx.power_switches.size() == 1 \
		and game.ctx.radios.size() == 1
	var quest: QuestData = Content.get_quest("quest.depot_signal")
	var points0 := game.economy.points
	Events.interacted.emit("power_depot", game.player)
	await get_tree().create_timer(0.1).timeout
	var door: DoorState = game.ctx.doors.get("door1", null)
	var powered: bool = door != null and door.open
	Events.interacted.emit("radio_depot", game.player)
	await get_tree().create_timer(0.1).timeout
	var done: bool = game.quest_system.is_complete(quest.id)
	var paid := game.economy.points >= points0 + 250
	var ok: bool = map_ok and powered and done and paid
	print("SECOND_MAP_TEST map=%s doors=%d wallbuys=%d power=%d radio=%d powered=%s quest=%s" % [
		game.map.id, game.ctx.doors.size(), game.ctx.wallbuys.size(),
		game.ctx.power_switches.size(), game.ctx.radios.size(),
		str(powered), str(done),
	])
	_finish("SECOND_MAP_OK", ok)

func _ui() -> void:
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	game.get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_start.png")
	get_tree().quit(0)

func _shot() -> void:
	game._start()
	game.economy.set_points(20000)
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	game.get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_a.png")
	game._on_interacted("door1", game.player)
	await get_tree().create_timer(0.7).timeout
	await RenderingServer.frame_post_draw
	game.get_viewport().get_texture().get_image().save_png("/tmp/opencode/slice_b.png")
	get_tree().quit(0)

func _bench() -> void:
	game._start()
	await get_tree().create_timer(3.0).timeout
	var fps := Engine.get_frames_per_second()
	var proc := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var draw := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	print("BENCH fps=%.1f process_ms=%.2f draw_calls=%d memory_mb=%.1f" % [fps, proc, int(draw), mem])
	get_tree().quit(0)

func _mouse() -> void:
	game._start()
	await get_tree().create_timer(0.2).timeout
	if DisplayServer.get_name() == "headless":
		print("MOUSE_SKIP headless")
		get_tree().quit(0)
		return
	var before := game.player.rotation.y
	var ev := InputEventMouseMotion.new()
	ev.relative = Vector2(160, 0)
	Input.parse_input_event(ev)
	await get_tree().create_timer(0.2).timeout
	var after := game.player.rotation.y
	var ok: bool = absf(after - before) > 0.0001
	print("MOUSE_TEST mode=%d before=%.4f after=%.4f ok=%s" % [Input.mouse_mode, before, after, str(ok)])
	_finish("MOUSE_OK", ok)

func _pause_shot() -> void:
	game._start()
	await get_tree().create_timer(0.5).timeout
	game._pause()
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	game.get_viewport().get_texture().get_image().save_png("/tmp/opencode/pause_bunker13.png")
	get_tree().quit(0)
