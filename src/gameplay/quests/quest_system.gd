class_name QuestSystem
extends Node

## Executa quests data-driven em sequência. Eventos fora de ordem são ignorados.

signal reward_granted(type: String, id: String, amount: int)

var player: PlayerController
var nav: MapNav
var quests: Array[QuestData] = []
var _states: Dictionary = {}
var _started := false
var _area_timer := 0.0
var _last_room := ""

func setup(p_quests: Array[QuestData], p_player: PlayerController,
		p_nav: MapNav = null) -> void:
	quests = p_quests
	player = p_player
	nav = p_nav
	_states.clear()
	for quest in quests:
		_states[quest.id] = {
			"index": 0,
			"counts": {},
			"done": false,
		}
	Events.interacted.connect(_on_interacted)
	Events.zombie_killed.connect(_on_zombie_killed)
	Events.power_on.connect(_on_power_on)

func start_all() -> void:
	if _started:
		return
	_started = true
	for quest in quests:
		_announce_step(quest)

func step_index(quest_id: String) -> int:
	var state: Dictionary = _states.get(quest_id, {})
	return int(state.get("index", 0))

func is_complete(quest_id: String) -> bool:
	var state: Dictionary = _states.get(quest_id, {})
	return bool(state.get("done", false))

func notify(trigger: String, target: String, amount := 1) -> bool:
	var matched := false
	for quest in quests:
		var state: Dictionary = _states[quest.id]
		if state.get("done", false):
			continue
		var index: int = state["index"]
		if index >= quest.steps.size():
			continue
		var step: QuestStepData = quest.steps[index]
		if step.trigger != trigger:
			continue
		if step.target != "any" and step.target != target:
			continue
		matched = true
		var counts: Dictionary = state["counts"]
		var current := int(counts.get(step.id, 0)) + amount
		counts[step.id] = current
		if current < step.count:
			continue
		state["index"] = index + 1
		state["counts"] = counts
		if int(state["index"]) >= quest.steps.size():
			state["done"] = true
			Events.quest_completed.emit(quest.id)
			Events.banner.emit(quest.name, "CONCLUÍDA", 3.0)
			_grant_rewards(quest)
			if quest.repeatable:
				state["index"] = 0
				state["counts"] = {}
				state["done"] = false
		else:
			_announce_step(quest)
	return matched

func notify_interact(id: String) -> void:
	notify("interact", id)

func notify_kill(enemy_id: String) -> void:
	if not notify("kill", enemy_id):
		notify("kill", "any")

func notify_enter_area(area_id: String) -> void:
	notify("enter_area", area_id)

func notify_collect(item_id: String) -> void:
	notify("collect", item_id)

func snapshot() -> Dictionary:
	var out := {}
	for quest_id in _states:
		var state: Dictionary = _states[quest_id]
		out[quest_id] = {
			"index": int(state.get("index", 0)),
			"counts": state.get("counts", {}).duplicate(),
			"done": bool(state.get("done", false)),
		}
	return out

func restore(data: Dictionary) -> void:
	for quest_id in _states:
		if not data.has(quest_id):
			continue
		var saved: Dictionary = data[quest_id]
		var state: Dictionary = _states[quest_id]
		state["index"] = int(saved.get("index", 0))
		state["counts"] = saved.get("counts", {}).duplicate()
		state["done"] = bool(saved.get("done", false))

func _grant_rewards(quest: QuestData) -> void:
	for reward in quest.rewards:
		reward_granted.emit(reward.type, reward.id, reward.amount)

func _announce_step(quest: QuestData) -> void:
	var index := step_index(quest.id)
	if index >= quest.steps.size():
		return
	var step: QuestStepData = quest.steps[index]
	var hint := step.hint if step.hint != "" else step.target
	Events.quest_step.emit(quest.id, step.id)
	Events.banner.emit(quest.name, hint, 2.0)

func _process(delta: float) -> void:
	if not _started or player == null or nav == null:
		return
	_area_timer -= delta
	if _area_timer > 0.0:
		return
	_area_timer = 0.25
	var room := nav.room_at(player.global_position)
	if room != "" and room != _last_room:
		_last_room = room
		notify_enter_area(room)

func _on_interacted(id: String, _player: Node) -> void:
	notify_interact(id)

func _on_power_on(id: String) -> void:
	notify("power", id)

func _on_zombie_killed(zombie: Node, _headshot: bool) -> void:
	if zombie == null or zombie.get("data") == null:
		notify_kill("any")
		return
	notify_kill(String(zombie.data.id))
