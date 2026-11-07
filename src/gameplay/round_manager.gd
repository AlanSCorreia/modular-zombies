class_name RoundManager
extends RefCounted

## Ondas, spawns em salas alcançáveis e conclusão da rodada.

signal spawn_requested(position: Vector3)
signal completed

var map: MapData
var nav: MapNav
var tree: SceneTree
var spawned := 0
var alive := 0
var complete := false
var active := false
var wave_pending := false

func setup(p_map: MapData, p_nav: MapNav, p_tree: SceneTree) -> void:
	map = p_map
	nav = p_nav
	tree = p_tree

func start() -> void:
	active = true
	complete = false
	spawned = 0
	alive = 0
	wave_pending = false
	_spawn_wave()

func stop() -> void:
	active = false

func notify_killed() -> void:
	if not active:
		return
	alive = maxi(0, alive - 1)
	if alive > 0:
		return
	if spawned < map.zombie_count:
		if not wave_pending:
			wave_pending = true
			tree.create_timer(0.6, false).timeout.connect(_spawn_wave)
	elif not complete:
		complete = true
		completed.emit()

func is_complete() -> bool:
	return complete

func _reachable_spawns() -> Array[SpawnData]:
	if nav == null:
		return map.zombie_spawns
	var rooms := nav.reachable_rooms()
	var out: Array[SpawnData] = []
	for s in map.zombie_spawns:
		if rooms.has(s.room):
			out.append(s)
	if out.is_empty():
		return map.zombie_spawns
	return out

func _spawn_wave() -> void:
	wave_pending = false
	if not active:
		return
	var pending := map.zombie_count - spawned
	if pending <= 0:
		return
	var available := _reachable_spawns()
	if available.is_empty():
		return
	var total := mini(pending, mini(3, available.size()))
	var base := spawned
	for i in range(total):
		var s: SpawnData = available[(base + i) % available.size()]
		spawn_requested.emit(s.position)
	spawned += total
	alive += total
