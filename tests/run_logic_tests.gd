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
	var weapon: WeaponData = reg.get_weapon("weapon.glock17")
	var enemy: EnemyData = reg.get_enemy("enemy.zombie")

	check(reg.errors.is_empty(), "conteúdo sem erros")
	check(map != null, "mapa carregado")
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
		check(weapon.scene.ends_with("glock17.glb"), "cena da Glock")
	if enemy != null:
		check(enemy.health == 100.0, "zumbi tem 100 de vida")
		check(enemy.speed > 0.0, "zumbi se move")
		check(enemy.scene.ends_with("zombie_dook_climb.glb"), "cena do zumbi")

	reg.free()
	print("LOGIC_OK" if fails == 0 else "LOGIC_FAIL (%d)" % fails)
	quit(0 if fails == 0 else 1)
