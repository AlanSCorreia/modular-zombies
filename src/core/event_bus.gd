extends Node

## Barramento de eventos global. O núcleo não conhece mapas; sistemas reagem.

signal round_started(round_no: int)
signal round_ended(round_no: int)
signal zombie_killed(zombie: Node, headshot: bool)
signal zombie_hit(zombie: Node, damage: float, headshot: bool, pos: Vector3)
signal points_changed(points: int)
signal player_damaged(amount: float)
signal player_died
signal player_health_changed(hp: float, max_hp: float)
signal ammo_changed(mag: int, reserve: int, weapon_name: String)
signal weapon_changed(id: String, name: String)
signal slot_changed(index: int, count: int)
signal door_opened(id: String, room: String)
signal power_on
signal interacted(id: String, player: Node)
signal quest_step(id: String, target: String)
signal quest_completed(id: String)
signal prompt_changed(text: String, affordable: bool)
signal game_state_changed(state: int)
signal banner(title: String, subtitle: String, duration: float)
signal hitmarker
signal damage_flash

func reset() -> void:
	pass
