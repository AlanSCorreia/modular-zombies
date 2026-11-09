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
var economy: Economy
var round: RoundManager
var barricade_system: BarricadeSystem
var quest_system: QuestSystem
var zombies: Array[ZombieEnemy] = []
var started := false
var owned_perks: Array[String] = []

func _ready() -> void:
	randomize()
	GameSettings.ensure_loaded()
	GameSettings.apply_quality(get_viewport())
	GameSettings.apply_audio()
	_setup_environment()

	var args := OS.get_cmdline_user_args()
	var map_id := MapArgs.map_id_from_args(args)
	map = Content.get_map(map_id)
	weapon_data = Content.get_weapon(map.starting_weapon) if map != null else null
	enemy_data = Content.get_enemy(map.enemy_id) if map != null else null
	if map == null or weapon_data == null or enemy_data == null:
		push_error("Conteúdo incompleto para o mapa '%s'" % map_id)
		return

	var builder := MapBuilderRegistry.create(map.builder)
	if builder == null:
		push_error("Builder inválido para o mapa %s: %s" % [map.id, map.builder])
		return
	ctx = builder.build(self, map, Content.explosives)
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
	hud.menu_requested.connect(_return_to_menu)

	player.setup_weapon(weapon_data)
	player.setup_melee(Content.get_melee("melee.knife"))
	player.setup_grenades(Content.get_explosive("explosive.frag"))

	economy = Economy.new()
	economy.setup(map.starting_points)
	barricade_system = BarricadeSystem.new()
	barricade_system.name = "BarricadeSystem"
	barricade_system.setup(player, economy, ctx.barricades)
	add_child(barricade_system)

	quest_system = QuestSystem.new()
	quest_system.name = "QuestSystem"
	var quest_list: Array[QuestData] = []
	for quest in Content.quests.values():
		quest_list.append(quest)
	quest_system.setup(quest_list, player, nav)
	quest_system.reward_granted.connect(_on_quest_reward)
	add_child(quest_system)
	round = RoundManager.new()
	round.setup(map, nav, get_tree())
	round.spawn_requested.connect(_spawn_at)
	round.completed.connect(_on_round_completed)
	round.round_started.connect(_on_round_started)
	Events.player_health_changed.emit(player.health, player.max_health)
	Events.zombie_killed.connect(_on_zombie_killed)
	Events.zombie_hit.connect(_on_zombie_hit)
	Events.interacted.connect(_on_interacted)
	Events.player_died.connect(_on_player_died)
	hud.show_start()
	if GameFlow.auto_start:
		GameFlow.reset()
		_start()


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
	round.start()
	if quest_system != null:
		quest_system.start_all()
	print("GAME_STARTED map=%s" % map.id)
	Events.banner.emit(map.name.to_upper(), "SOBREVIVA E ABRA AS PORTAS", 2.5)

func _on_pause_toggled() -> void:
	if not started or player == null or player.is_dead:
		return
	if get_tree().paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	if round == null or round.is_complete() or player == null or player.is_dead:
		return
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_pause()

func _resume() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.hide_pause()

func _spawn_at(pos: Vector3, barricade_id := "", enemy_id := "") -> void:
	var spawn_data: EnemyData = enemy_data
	if enemy_id != "":
		var special := Content.get_enemy(enemy_id)
		if special != null:
			spawn_data = special
	var z := ZombieEnemy.new()
	z.setup(spawn_data, player, nav)
	z.position = pos
	add_child(z)
	zombies.append(z)
	if barricade_id != "" and ctx.barricades.has(barricade_id):
		z.setup_barricade(ctx.barricades[barricade_id], barricade_system)

func _on_zombie_killed(z: ZombieEnemy, headshot: bool) -> void:
	zombies.erase(z)
	var gain := 100 if headshot else 50
	economy.add(gain)
	Events.banner.emit("ZUMBI ELIMINADO", "+%d PONTOS" % gain, 1.2)
	round.notify_killed()

func _on_zombie_hit(_z: ZombieEnemy, _damage: float, _head: bool, _pos: Vector3) -> void:
	economy.add(10)

func _on_round_completed() -> void:
	var ended := round.round_no
	Sfx.play_music("round_end", -6)
	Events.banner.emit("RODADA %d CONCLUÍDA" % ended, "PREPARE-SE", 2.5)
	if player != null and not player.is_dead:
		get_tree().create_timer(4.0).timeout.connect(_advance_round)

func _advance_round() -> void:
	if round == null or player == null or player.is_dead or not round.active:
		return
	round.next_round()

func _on_round_started(round_no: int) -> void:
	hud.set_round(round_no)
	Sfx.play_music("round_start", -8)
	if round_no > 1:
		Events.banner.emit("RODADA %d" % round_no, "SOBREVIVA", 2.0)

func _on_quest_reward(type: String, id: String, amount: int) -> void:
	match type:
		"points":
			economy.add(amount)
		"music":
			if Sfx.has(id):
				Sfx.play_music(id, -6)
			else:
				Sfx.play_music("round_start", -8)
		"weapon":
			var weapon: WeaponData = Content.get_weapon(id)
			if weapon != null:
				player.add_weapon(weapon)
		"perk":
			if not owned_perks.has(id):
				owned_perks.append(id)
				Events.banner.emit("PERK GRÁTIS", id.to_upper(), 1.8)

func _on_interacted(id: String, _who: Node) -> void:
	if ctx.doors.has(id):
		_buy_door(id)
	elif ctx.wallbuys.has(id):
		_buy_wallbuy(id)
	elif ctx.perks.has(id):
		_buy_perk(id)
	elif ctx.box != null and id == ctx.box.id:
		_buy_box()
	elif ctx.radios.has(id):
		_use_radio(id)
	elif ctx.power_switches.has(id):
		_activate_power(id)

func _can_pay(cost: int) -> bool:
	if economy.can_afford(cost):
		return true
	Events.banner.emit("PONTOS INSUFICIENTES", "FALTAM %d" % (cost - economy.points), 1.6)
	return false

func _spend(cost: int) -> void:
	economy.spend(cost)

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

func _activate_power(id: String) -> void:
	var sw: PowerSwitchState = ctx.power_switches.get(id, null)
	if sw == null or sw.used:
		return
	sw.used = true
	if sw.label != null:
		sw.label.visible = false
	for light in ctx.power_lights:
		light.visible = true
	Events.power_on.emit(id)
	Sfx.play("powerup", -3)
	Events.banner.emit("ENERGIA LIGADA", "SETORES LIBERADOS", 2.0)
	if sw.data != null and sw.data.door_id != "":
		_open_door_free(sw.data.door_id)

func _open_door_free(id: String) -> void:
	var door: DoorState = ctx.doors.get(id, null)
	if door == null or door.open:
		return
	door.open = true
	if door.body != null:
		door.body.queue_free()
	if door.label != null:
		door.label.queue_free()
	var node: Node3D = door.node
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(node, "position:y", node.position.y + 2.8, 0.7)

func _use_radio(id: String) -> void:
	var radio: RadioState = ctx.radios.get(id, null)
	if radio == null or radio.used:
		return
	radio.used = true
	if radio.label != null:
		radio.label.visible = false
	Sfx.play_3d("radio", radio.node.global_position, -4, 1.0, 0.05)
	Events.banner.emit("RÁDIO", "SINTONIZADO", 1.2)

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
	if round != null:
		round.stop()
	get_tree().paused = false
	hud.hide_pause()
	hud.show_gameover()

func _return_to_menu() -> void:
	get_tree().paused = false
	GameFlow.reset()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Sfx.stop_music()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _restart() -> void:
	get_tree().paused = false
	hud.hide_pause()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if started and player != null and not player.is_dead:
			if event.keycode == KEY_F5:
				_save_game()
				return
			if event.keycode == KEY_F9:
				_load_game()
				return
	if round != null and round.is_complete() and event is InputEventKey \
		and event.pressed and event.keycode == KEY_R:
		_restart()

func _save_game() -> void:
	var save := SaveGame.new()
	if save.save_game(self):
		Events.banner.emit("JOGO SALVO", "F9 PARA CARREGAR", 1.6)
	else:
		Events.banner.emit("FALHA AO SALVAR", save.last_error, 2.0)

func _load_game() -> void:
	var save := SaveGame.new()
	if save.load_game(self):
		Events.banner.emit("JOGO CARREGADO", "F5 PARA SALVAR", 1.6)
	else:
		Events.banner.emit("FALHA AO CARREGAR", save.last_error, 2.0)
