class_name QuestValidator
extends RefCounted

## Valida quests antes do runtime: referências, passos órfãos, ciclos e
## recompensas. O grafo usa `next` quando explícito; senão, o próximo índice.

const TRIGGERS := ["interact", "kill", "enter_area", "collect", "power"]
const REWARD_TYPES := ["points", "music", "weapon", "perk"]

static func validate(quests: Dictionary, maps: Dictionary,
		weapons: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for quest_id in quests.keys():
		var q: QuestData = quests[quest_id]
		if q.id == "" or q.name == "":
			errors.append("quest %s: id/name vazios" % quest_id)
		var scoped := maps
		if q.map != "":
			if not maps.has(q.map):
				errors.append("quest %s: mapa inexistente (%s)" % [quest_id, q.map])
				continue
			scoped = {q.map: maps[q.map]}
		var ids := _collect_ids(scoped)
		var interact_ids: Dictionary = ids["interact"]
		var room_ids: Dictionary = ids["room"]
		var power_ids: Dictionary = ids["power"]
		var perk_ids: Dictionary = ids["perk"]
		var enemy_ids: Dictionary = ids["enemy"]
		if q.steps.is_empty():
			errors.append("quest %s: sem passos" % quest_id)
			continue
		var step_ids := {}
		for step in q.steps:
			if step.id == "" or step.target == "":
				errors.append("quest %s: passo sem id/target" % quest_id)
			if step_ids.has(step.id):
				errors.append("quest %s: passo duplicado %s" % [quest_id, step.id])
			step_ids[step.id] = true
			if not TRIGGERS.has(step.trigger):
				errors.append("quest %s: trigger inválido %s" % [quest_id, step.trigger])
			if step.count < 1:
				errors.append("quest %s: count < 1 em %s" % [quest_id, step.id])
			if step.trigger == "interact" and step.target != "any" \
				and not interact_ids.has(step.target):
				errors.append("quest %s: alvo de interact inexistente (%s)" % [quest_id, step.target])
			if step.trigger == "enter_area" and step.target != "any" \
				and not room_ids.has(step.target):
				errors.append("quest %s: área inexistente (%s)" % [quest_id, step.target])
			if step.trigger == "kill" and step.target != "any" \
				and not enemy_ids.has(step.target):
				errors.append("quest %s: inimigo inexistente (%s)" % [quest_id, step.target])
			if step.trigger == "power" and not power_ids.has(step.target):
				errors.append("quest %s: interruptor inexistente (%s)" % [quest_id, step.target])
			for nxt in step.next_steps:
				if not step_ids.has(nxt) and not _has_step_id(q, nxt):
					errors.append("quest %s: next inexistente (%s)" % [quest_id, nxt])
		for reward in q.rewards:
			if not REWARD_TYPES.has(reward.type):
				errors.append("quest %s: reward inválido %s" % [quest_id, reward.type])
			if reward.type == "points" and reward.amount <= 0:
				errors.append("quest %s: points <= 0" % quest_id)
			if reward.type in ["music", "weapon", "perk"] and reward.id == "":
				errors.append("quest %s: reward %s sem id" % [quest_id, reward.type])
			if reward.type == "weapon" and not weapons.has(reward.id):
				errors.append("quest %s: arma de reward inexistente (%s)" % [quest_id, reward.id])
			if reward.type == "perk" and not perk_ids.has(reward.id):
				errors.append("quest %s: perk de reward inexistente (%s)" % [quest_id, reward.id])
		_check_graph(q, errors)
	return errors


static func _collect_ids(maps: Dictionary) -> Dictionary:
	var interact_ids := {}
	var room_ids := {}
	var power_ids := {}
	var perk_ids := {}
	var enemy_ids := {}
	for map_id in maps.keys():
		var m: MapData = maps[map_id]
		if m == null:
			continue
		for room in m.rooms:
			room_ids[room.id] = true
		for door in m.doors:
			interact_ids[door.id] = true
		for wallbuy in m.wallbuys:
			interact_ids[wallbuy.id] = true
		for perk in m.perks:
			interact_ids[perk.id] = true
			perk_ids[perk.id] = true
		for barricade in m.barricades:
			interact_ids[barricade.id] = true
		for radio in m.radios:
			interact_ids[radio.id] = true
		for power in m.power_switches:
			interact_ids[power.id] = true
			power_ids[power.id] = true
		if m.box != null:
			interact_ids["box"] = true
		if m.enemy_id != "":
			enemy_ids[m.enemy_id] = true
	return {
		"interact": interact_ids,
		"room": room_ids,
		"power": power_ids,
		"perk": perk_ids,
		"enemy": enemy_ids,
	}

static func _has_step_id(q: QuestData, id: String) -> bool:
	for step in q.steps:
		if step.id == id:
			return true
	return false

static func _check_graph(q: QuestData, errors: Array[String]) -> void:
	var index_by_id := {}
	for i in range(q.steps.size()):
		index_by_id[q.steps[i].id] = i
	var visited := {}
	var active := {}
	var cycle := _walk(q, q.steps[0].id, index_by_id, visited, active)
	if cycle:
		errors.append("quest %s: ciclo no grafo" % q.id)
	for step in q.steps:
		if not visited.has(step.id):
			errors.append("quest %s: passo órfão %s" % [q.id, step.id])

static func _walk(q: QuestData, id: String, index_by_id: Dictionary,
		visited: Dictionary, active: Dictionary) -> bool:
	if active.has(id):
		return true
	if visited.has(id):
		return false
	active[id] = true
	var index: int = index_by_id.get(id, -1)
	if index >= 0:
		var step := q.steps[index]
		var nexts: Array[String] = []
		if not step.next_steps.is_empty():
			nexts = step.next_steps
		elif index + 1 < q.steps.size():
			nexts = [q.steps[index + 1].id]
		for nxt in nexts:
			if index_by_id.has(nxt) \
				and _walk(q, nxt, index_by_id, visited, active):
				return true
	active.erase(id)
	visited[id] = true
	return false
