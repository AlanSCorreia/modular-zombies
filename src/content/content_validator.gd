class_name ContentValidator
extends RefCounted

static func validate(maps: Dictionary, weapons: Dictionary, enemies: Dictionary, melees: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for id in maps.keys():
		var m: MapData = maps[id]
		if m.id == "" or m.name == "":
			errors.append("map %s: id/name vazios" % id)
		if m.builder == "":
			errors.append("map %s: builder ausente" % id)
		if m.scene == "" or not FileAccess.file_exists(m.scene):
			errors.append("map %s: cena inexistente (%s)" % [id, m.scene])
		if m.rooms.is_empty():
			errors.append("map %s: sem rooms" % id)
		if m.doors.size() > 0 and m.rooms.is_empty():
			errors.append("map %s: portas sem rooms" % id)
		var room_ids := {}
		for r in m.rooms:
			room_ids[r.id] = true
			if r.rect.size.x <= 0.1 or r.rect.size.y <= 0.1:
				errors.append("map %s: room %s inválido" % [id, r.id])
		for d in m.doors:
			if d.id == "":
				errors.append("map %s: porta sem id" % id)
			if d.cost < 0:
				errors.append("map %s: porta %s custo negativo" % [id, d.id])
			if not room_ids.has(d.room):
				errors.append("map %s: porta %s aponta para room inexistente (%s)" % [id, d.id, d.room])
			if d.size.x <= 0 or d.size.y <= 0 or d.size.z <= 0:
				errors.append("map %s: porta %s com size inválido" % [id, d.id])
		for s in m.zombie_spawns:
			if not room_ids.has(s.room):
				errors.append("map %s: spawn %s aponta para room inexistente" % [id, s.id])
		for wb in m.wallbuys:
			if wb.id == "" or wb.weapon_id == "":
				errors.append("map %s: wallbuy sem id/weapon" % id)
			if not weapons.has(wb.weapon_id):
				errors.append("map %s: wallbuy %s usa arma inexistente (%s)" % [id, wb.id, wb.weapon_id])
			if wb.cost < 0:
				errors.append("map %s: wallbuy %s custo negativo" % [id, wb.id])
		for perk in m.perks:
			if perk.id == "" or perk.name == "":
				errors.append("map %s: perk sem id/name" % id)
			if perk.cost < 0:
				errors.append("map %s: perk %s custo negativo" % [id, perk.id])
		if m.box != null and m.box.cost < 0:
			errors.append("map %s: box custo negativo" % id)
		for b in m.barricades:
			if b.id == "":
				errors.append("map %s: barricada sem id" % id)
			if not room_ids.has(b.room):
				errors.append("map %s: barricada %s aponta para room inexistente" % [id, b.id])
			if b.max_planks <= 0:
				errors.append("map %s: barricada %s com max_planks <= 0" % [id, b.id])
		if m.enemy_id == "" or not enemies.has(m.enemy_id):
			errors.append("map %s: enemy '%s' inexistente" % [id, m.enemy_id])
		if m.starting_points < 0:
			errors.append("map %s: starting_points negativo" % id)
		if m.zombie_count < 1:
			errors.append("map %s: zombie_count < 1" % id)

	for id in weapons.keys():
		var w: WeaponData = weapons[id]
		if w.id == "" or w.name == "":
			errors.append("weapon %s: id/name vazios" % id)
		if w.scene == "" or not FileAccess.file_exists(w.scene):
			errors.append("weapon %s: cena inexistente (%s)" % [id, w.scene])
		if w.grip_profile == "":
			errors.append("weapon %s: grip_profile ausente" % id)
		for key in ["damage", "rpm", "mag", "reserve", "reload_chambered"]:
			if not w.stats.has(key):
				errors.append("weapon %s: stat '%s' ausente" % [id, key])
		if float(w.stats.get("damage", 0.0)) <= 0.0:
			errors.append("weapon %s: damage <= 0" % id)
		if int(w.stats.get("mag", 0)) <= 0:
			errors.append("weapon %s: mag <= 0" % id)
		if w.type == "projectile":
			if w.projectile.is_empty():
				errors.append("weapon %s: type projectile sem bloco projectile" % id)
			else:
				if float(w.projectile.get("speed", 0.0)) <= 0.0:
					errors.append("weapon %s: projectile.speed <= 0" % id)
				if float(w.projectile.get("lifetime", 0.0)) <= 0.0:
					errors.append("weapon %s: projectile.lifetime <= 0" % id)

	for id in enemies.keys():
		var e: EnemyData = enemies[id]
		if e.id == "" or e.name == "":
			errors.append("enemy %s: id/name vazios" % id)
		if e.scene == "" or not FileAccess.file_exists(e.scene):
			errors.append("enemy %s: cena inexistente (%s)" % [id, e.scene])
		if e.health <= 0.0 or e.speed <= 0.0 or e.damage <= 0.0:
			errors.append("enemy %s: stats inválidos" % id)

	for id in melees.keys():
		var m: MeleeData = melees[id]
		if m.id == "" or m.name == "":
			errors.append("melee %s: id/name vazios" % id)
		if m.damage <= 0.0 or m.range <= 0.0 or m.cooldown <= 0.0:
			errors.append("melee %s: stats inválidos" % id)
		if m.scene != "" and not FileAccess.file_exists(m.scene):
			errors.append("melee %s: cena inexistente (%s)" % [id, m.scene])
	return errors
