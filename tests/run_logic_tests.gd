extends SceneTree

var fails := 0

func check(cond: bool, name: String) -> void:
	if cond:
		print("PASS  ", name)
	else:
		fails += 1
		print("FAIL  ", name)

func _init() -> void:
	var reg := ContentRegistry.new()
	reg.reload()
	print("maps=", reg.maps.size(), " weapons=", reg.weapons.size(), " enemies=", reg.enemies.size(), " errors=", reg.errors.size())

	var map: MapData = reg.get_map("map.slice")
	var bunker: MapData = reg.get_map("map.bunker13")
	var weapon: WeaponData = reg.get_weapon("weapon.glock17")
	var enemy: EnemyData = reg.get_enemy("enemy.zombie")
	var melee: MeleeData = reg.get_melee("melee.knife")
	var explosive: ExplosiveData = reg.get_explosive("explosive.frag")
	var quest: QuestData = reg.get_quest("quest.bunker13_music")
	var power_quest: QuestData = reg.get_quest("quest.bunker13_power")

	check(reg.errors.is_empty(), "conteúdo sem erros")
	check(reg.maps.size() == 2, "2 mapas carregados")
	check(reg.weapons.size() == 6, "6 armas carregadas")
	check(reg.melees.size() == 1, "1 melee carregado")
	check(reg.explosives.size() == 1, "1 explosivo carregado")
	check(reg.quests.size() == 2, "2 quests carregadas")
	check(melee != null, "faca carregada")
	check(explosive != null, "granada carregada")
	check(quest != null, "quest carregada")
	check(power_quest != null, "quest de energia carregada")
	if melee != null:
		check(melee.damage == 150.0, "faca causa 150")
		check(melee.cooldown > 0.0, "faca tem cooldown")
	if explosive != null:
		check(explosive.radius == 4.0, "granada tem raio 4")
		check(explosive.chain_depth == 2, "granada encadeia")
	if quest != null:
		check(quest.steps.size() == 3, "quest tem 3 passos")
		check(quest.rewards.size() == 2, "quest tem 2 recompensas")
	for wid in ["weapon.glock17", "weapon.mp5", "weapon.m870", "weapon.ak74", "weapon.wunder", "weapon.rocket"]:
		var w: WeaponData = reg.get_weapon(wid)
		check(w != null, "arma " + wid)
		if w != null:
			check(w.grip_profile != "", wid + " tem grip")
			check(FileAccess.file_exists(w.scene), wid + " cena existe")
	check(map != null, "mapa slice carregado")
	check(bunker != null, "mapa Bunker 13 carregado")
	check(weapon != null, "arma carregada")
	check(enemy != null, "inimigo carregado")
	check(MapBuilderRegistry.has("scene"), "builder scene registrado")
	check(not MapBuilderRegistry.has("bunker13"), "builder legado fora do runtime")
	check(not MapBuilderRegistry.has("inexistente"), "builder desconhecido rejeitado")
	check(MapArgs.map_id_from_args(PackedStringArray(["--map", "map.bunker13"])) == "map.bunker13", "--map lê o mapa")
	check(MapArgs.map_id_from_args(PackedStringArray([])) == "map.slice", "--map usa slice por padrão")
	if map != null:
		check(map.builder == "scene", "slice usa builder scene")
		check(map.scene != "" and FileAccess.file_exists(map.scene), "slice tem cena autoral")
		check(map.rooms.size() == 2, "mapa tem 2 salas")
		check(map.doors.size() == 1, "mapa tem 1 porta")
		check(map.doors[0].cost == 500, "porta custa 500")
		check(map.zombie_spawns.size() == 2, "mapa tem 2 spawns")
		check(map.enemy_id == "enemy.zombie", "mapa referencia o zumbi")
		check(map.starting_points == 500, "pontos iniciais 500")
		check(map.player_spawn.length() > 0.0, "spawn do player definido")
	if weapon != null:
		check(int(weapon.stats.get("mag", 0)) == 17, "Glock tem 17 tiros")
		check(float(weapon.stats.get("damage", 0)) == 34.0, "Glock causa 34")
		check(weapon.type == "hitscan", "Glock é hitscan")
		check(weapon.scene.ends_with("weapons/glock17/glock17.glb"), "cena da Glock")
	if bunker != null:
		check(bunker.builder == "scene", "Bunker 13 usa builder scene")
		check(bunker.scene != "" and FileAccess.file_exists(bunker.scene), "Bunker 13 tem cena autoral")
		check(bunker.rooms.size() == 4, "Bunker 13 tem 4 salas")
		check(bunker.doors.size() == 4, "Bunker 13 tem 4 portas")
		check(bunker.wallbuys.size() == 4, "Bunker 13 tem 4 wallbuys")
		check(bunker.perks.size() == 3, "Bunker 13 tem 3 perks")
		check(bunker.box != null, "Bunker 13 tem caixa")
		check(bunker.barricades.size() == 9, "Bunker 13 tem 9 barricadas")
		check(bunker.barrels.size() == 2, "Bunker 13 tem 2 barris")
		check(bunker.traps.size() == 2, "Bunker 13 tem 2 traps")
		check(bunker.radios.size() == 3, "Bunker 13 tem 3 rádios")
		check(bunker.zombie_spawns.size() == 9, "Bunker 13 tem 9 spawns")
	if enemy != null:
		check(enemy.health == 100.0, "zumbi tem 100 de vida")
		check(enemy.speed > 0.0, "zumbi se move")
		check(enemy.scene.ends_with("enemies/zombie/zombie.glb"), "cena do zumbi")

	reg.free()
	print("LOGIC_OK" if fails == 0 else "LOGIC_FAIL (%d)" % fails)
	quit(0 if fails == 0 else 1)
