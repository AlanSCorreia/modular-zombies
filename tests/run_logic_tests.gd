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

	check(reg.errors.is_empty(), "conteúdo sem erros")
	check(reg.maps.size() == 2, "2 mapas carregados")
	check(reg.weapons.size() == 5, "5 armas carregadas")
	for wid in ["weapon.glock17", "weapon.mp5", "weapon.m870", "weapon.ak74", "weapon.wunder"]:
		var w: WeaponData = reg.get_weapon(wid)
		check(w != null, "arma " + wid)
		if w != null:
			check(w.grip_profile != "", wid + " tem grip")
			check(FileAccess.file_exists(w.scene), wid + " cena existe")
	check(map != null, "mapa slice carregado")
	check(bunker != null, "mapa Bunker 13 carregado")
	check(weapon != null, "arma carregada")
	check(enemy != null, "inimigo carregado")
	if map != null:
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
		check(bunker.rooms.size() == 4, "Bunker 13 tem 4 salas")
		check(bunker.doors.size() == 4, "Bunker 13 tem 4 portas")
		check(bunker.wallbuys.size() == 4, "Bunker 13 tem 4 wallbuys")
		check(bunker.perks.size() == 3, "Bunker 13 tem 3 perks")
		check(bunker.box != null, "Bunker 13 tem caixa")
		check(bunker.barricades.size() == 9, "Bunker 13 tem 9 barricadas")
		check(bunker.zombie_spawns.size() == 9, "Bunker 13 tem 9 spawns")
	if enemy != null:
		check(enemy.health == 100.0, "zumbi tem 100 de vida")
		check(enemy.speed > 0.0, "zumbi se move")
		check(enemy.scene.ends_with("enemies/zombie/zombie.glb"), "cena do zumbi")

	reg.free()
	print("LOGIC_OK" if fails == 0 else "LOGIC_FAIL (%d)" % fails)
	quit(0 if fails == 0 else 1)
