class_name SaveGame
extends RefCounted

## Save versionado do estado da run. JSON simples em `user://`.

const VERSION := 1
const DEFAULT_PATH := "user://savegame.json"

var last_error := ""

func save_game(game: GameRoot, path := DEFAULT_PATH) -> bool:
	if game == null or game.player == null:
		last_error = "jogo inválido"
		return false
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
		"perks": game.owned_perks.duplicate(),
		"barricades": barricades,
		"powered": powered,
		"round": {
			"round_no": game.round.round_no,
			"target_count": game.round.target_count,
			"spawned": game.round.spawned,
			"alive": game.round.alive,
			"complete": game.round.complete,
			"active": game.round.active,
		},
		"quests": game.quest_system.snapshot(),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "não foi possível escrever " + path
		return false
	file.store_string(JSON.stringify(data, "  ", false) + "\n")
	file.close()
	last_error = ""
	return true

func load_game(game: GameRoot, path := DEFAULT_PATH) -> bool:
	if game == null or game.player == null:
		last_error = "jogo inválido"
		return false
	if not FileAccess.file_exists(path):
		last_error = "save inexistente"
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		last_error = "JSON inválido"
		return false
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != VERSION:
		last_error = "versão incompatível"
		return false
	if String(data.get("map", "")) != game.map.id:
		last_error = "save de outro mapa"
		return false

	game.economy.set_points(int(data.get("points", game.economy.points)))
	game.player.health = float(data.get("health", game.player.health))
	game.player.grenades = int(data.get("grenades", game.player.grenades))
	Events.grenades_changed.emit(game.player.grenades)
	Events.player_health_changed.emit(game.player.health, game.player.max_health)
	var pos: Array = data.get("player_pos", [])
	if pos.size() == 3:
		game.player.global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))

	for i in range(game.player.weapons.size()):
		game.player._free_slot(i)
	game.player.weapons.clear()
	game.player.weapon = null
	game.player.active_slot = 0
	for entry in data.get("weapons", []):
		var w: WeaponData = Content.get_weapon(String(entry.get("id", "")))
		if w == null:
			continue
		game.player.add_weapon(w)
		var controller: WeaponController = game.player.weapon
		if controller != null:
			controller.ammo_mag = int(entry.get("mag", controller.ammo_mag))
			controller.ammo_reserve = int(entry.get("reserve", controller.ammo_reserve))
			controller._update_ammo()

	game.owned_perks.clear()
	for perk in data.get("perks", []):
		game.owned_perks.append(String(perk))

	for id in data.get("barricades", {}):
		var b: BarricadeState = game.ctx.barricades.get(String(id), null)
		if b != null:
			b.set_plank_count(int(data["barricades"][id]))

	if bool(data.get("powered", false)):
		for sw in game.ctx.power_switches.values():
			sw.used = true
			if sw.label != null:
				sw.label.visible = false
			if sw.data != null and sw.data.door_id != "":
				game._open_door_free(sw.data.door_id)
		for light in game.ctx.power_lights:
			light.visible = true

	var round_data: Dictionary = data.get("round", {})
	game.round.round_no = int(round_data.get("round_no", game.round.round_no))
	game.round.target_count = int(round_data.get("target_count", game.round.target_count))
	game.round.spawned = int(round_data.get("spawned", game.round.spawned))
	game.round.alive = int(round_data.get("alive", game.round.alive))
	game.round.complete = bool(round_data.get("complete", game.round.complete))
	game.round.active = bool(round_data.get("active", game.round.active))
	game.hud.set_round(game.round.round_no)

	game.quest_system.restore(data.get("quests", {}))
	last_error = ""
	return true
