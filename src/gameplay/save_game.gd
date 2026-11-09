class_name SaveGame
extends RefCounted

## Save versionado do estado da run. JSON simples em `user://`.

const VERSION := 2
const DEFAULT_PATH := "user://savegame.json"

var last_error := ""

func save_game(game: GameRoot, path := DEFAULT_PATH) -> bool:
	if game == null or game.player == null:
		return _fail("jogo inválido")
	var weapons: Array = []
	for w in game.player.weapons:
		if w == null:
			continue
		weapons.append({
			"id": w.data.id,
			"mag": w.ammo_mag,
			"reserve": w.ammo_reserve,
		})
	var barricades := {}
	for id in game.ctx.barricades:
		var b: BarricadeState = game.ctx.barricades[id]
		barricades[id] = b.plank_count
	var doors: Array = []
	for id in game.ctx.doors:
		var door: DoorState = game.ctx.doors[id]
		if door.open:
			doors.append(id)
	var powered := false
	for sw in game.ctx.power_switches.values():
		if sw.used:
			powered = true
			break
	var data := {
		"version": VERSION,
		"map": game.map.id,
		"points": game.economy.points,
		"health": game.player.health,
		"grenades": game.player.grenades,
		"player_pos": [
			game.player.global_position.x,
			game.player.global_position.y,
			game.player.global_position.z,
		],
		"weapons": weapons,
		"active_slot": game.player.active_slot,
		"perks": game.owned_perks.duplicate(),
		"barricades": barricades,
		"doors": doors,
		"powered": powered,
		"round": {
			"round_no": game.round.round_no,
			"active": game.round.active,
		},
		"quests": game.quest_system.snapshot(),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _fail("não foi possível escrever " + path)
	file.store_string(JSON.stringify(data, "  ", false) + "\n")
	file.close()
	last_error = ""
	return true

func load_game(game: GameRoot, path := DEFAULT_PATH) -> bool:
	if game == null or game.player == null:
		return _fail("jogo inválido")
	if not FileAccess.file_exists(path):
		return _fail("save inexistente")
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return _fail("JSON inválido")
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != VERSION:
		return _fail("versão incompatível")
	if String(data.get("map", "")) != game.map.id:
		return _fail("save de outro mapa")

	game.economy.set_points(maxi(0, int(data.get("points", game.economy.points))))
	game.player.health = clampf(
		float(data.get("health", game.player.health)),
		1.0, game.player.max_health
	)
	game.player.grenades = clampi(
		int(data.get("grenades", game.player.grenades)),
		0, game.player.max_grenades
	)
	Events.grenades_changed.emit(game.player.grenades)
	Events.player_health_changed.emit(game.player.health, game.player.max_health)
	var pos: Array = data.get("player_pos", [])
	if pos.size() == 3:
		game.player.global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))

	for z in game.zombies.duplicate():
		if is_instance_valid(z):
			z.queue_free()
	game.zombies.clear()

	for i in range(game.player.weapons.size()):
		game.player._free_slot(i)
	game.player.weapons.clear()
	game.player.weapon = null
	game.player.active_slot = 0
	var restored := 0
	for entry in data.get("weapons", []):
		var w: WeaponData = Content.get_weapon(String(entry.get("id", "")))
		if w == null:
			continue
		game.player.add_weapon(w)
		restored += 1
		var controller: WeaponController = game.player.weapon
		if controller != null:
			controller.ammo_mag = clampi(int(entry.get("mag", controller.ammo_mag)),
				0, int(controller.data.stats.get("mag", controller.ammo_mag)))
			controller.ammo_reserve = maxi(0, int(entry.get("reserve", controller.ammo_reserve)))
			controller._update_ammo()
	if restored == 0:
		var fallback: WeaponData = Content.get_weapon(game.map.starting_weapon)
		if fallback != null:
			game.player.add_weapon(fallback)
	if not game.player.weapons.is_empty():
		var slot := clampi(int(data.get("active_slot", 0)), 0,
			game.player.weapons.size() - 1)
		game.player.switch_slot(slot)

	game.owned_perks.clear()
	for perk in data.get("perks", []):
		game.owned_perks.append(String(perk))

	for id in data.get("barricades", {}):
		var b: BarricadeState = game.ctx.barricades.get(String(id), null)
		if b != null:
			b.set_plank_count(clampi(int(data["barricades"][id]), 0, b.data.max_planks))

	var powered := bool(data.get("powered", false))
	game.power_on = powered
	if powered:
		for sw in game.ctx.power_switches.values():
			sw.used = true
			if sw.label != null:
				sw.label.visible = false
		for light in game.ctx.power_lights:
			light.visible = true
	var saved_doors: Array = data.get("doors", [])
	for id in saved_doors:
		game._open_door_free(String(id))
	if powered:
		for door in game.ctx.doors.values():
			if door.requires_power and not door.open:
				game._open_door_free(door.id)

	var round_data: Dictionary = data.get("round", {})
	var round_no := maxi(1, int(round_data.get("round_no", game.round.round_no)))
	game.round.stop()
	game.round.round_no = round_no
	if bool(round_data.get("active", false)):
		game.round.restart_at(round_no)
	else:
		game.round.complete = false
		game.round.spawned = 0
		game.round.alive = 0
		game.round.target_count = game.map.zombie_count + (round_no - 1) * 2
	game.hud.set_round(round_no)

	game.quest_system.restore(data.get("quests", {}))
	last_error = ""
	return true

func _fail(message: String) -> bool:
	last_error = message
	return false
