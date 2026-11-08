class_name RoundManager
extends RefCounted

## Ondas, spawns em salas alcançáveis e conclusão da rodada.

signal spawn_requested(position: Vector3, barricade_id: String)
signal completed
signal round_started(round_no: int)
signal round_ended(round_no: int)

var map: MapData
var nav: MapNav
var tree: SceneTree
var round_no := 0
var target_count := 0
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
	round_no = 1
	target_count = map.zombie_count
	spawned = 0
	alive = 0
	wave_pending = false
	round_started.emit(round_no)
	_spawn_wave()

## Avança para a próxima rodada; chamado pelo GameRoot após o intervalo.
func next_round() -> void:
	if not active:
		return
	round_no += 1
	target_count = map.zombie_count + (round_no - 1) * 2
	complete = false
	spawned = 0
	alive = 0
	wave_pending = false
	round_started.emit(round_no)
	_spawn_wave()

func stop() -> void:
	active = false

func notify_killed() -> void:
	if not active:
		return
	alive = maxi(0, alive - 1)
	if alive > 0:
		return
	if spawned < target_count:
		if not wave_pending:
			wave_pending = true
			tree.create_timer(0.6, false).timeout.connect(_spawn_wave)
	elif not complete:
		complete = true
		round_ended.emit(round_no)
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
	var pending := target_count - spawned
	if pending <= 0:
		return
	var barricades := _reachable_barricades()
	if not barricades.is_empty():
		var total := mini(pending, mini(3, barricades.size()))
		var base := spawned
		for i in range(total):
			var b: BarricadeData = barricades[(base + i) % barricades.size()]
			spawn_requested.emit(b.spawn_position, b.id)
		spawned += total
		alive += total
		return

	var available := _reachable_spawns()
	if available.is_empty():
		return
	var total := mini(pending, mini(3, available.size()))
	var base := spawned
	for i in range(total):
		var s: SpawnData = available[(base + i) % available.size()]
		spawn_requested.emit(s.position, "")
	spawned += total
	alive += total

func _reachable_barricades() -> Array[BarricadeData]:
	var out: Array[BarricadeData] = []
	if map.barricades.is_empty():
		return out
	var rooms := nav.reachable_rooms() if nav != null else []
	for b in map.barricades:
		if rooms.is_empty() or rooms.has(b.room):
			out.append(b)
	return out
