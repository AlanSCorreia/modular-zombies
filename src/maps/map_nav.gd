class_name MapNav
extends RefCounted

## Navegação simples por salas/portas. BFS sobre o grafo de salas abertas.
## Serve para spawns alcançáveis e para os zumbis não tentarem atravessar portas.

var map: MapData
var doors: Dictionary[String, DoorState] = {}
var start_room := ""
var edges: Dictionary = {}

func setup(p_map: MapData, p_doors: Dictionary[String, DoorState]) -> void:
	map = p_map
	doors = p_doors
	start_room = room_at(map.player_spawn)
	_build_edges()

func room_at(pos: Vector3) -> String:
	var p := Vector2(pos.x, pos.z)
	for r in map.rooms:
		if _contains(r.rect, p):
			return r.id
	return ""

func reachable_rooms() -> Array[String]:
	var out: Array[String] = []
	if start_room == "":
		for r in map.rooms:
			out.append(r.id)
		return out
	var queue: Array[String] = [start_room]
	var seen := {start_room: true}
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		for e in edges.get(cur, []):
			if not _is_open(e.door) or seen.has(e.room):
				continue
			seen[e.room] = true
			queue.append(e.room)
	for id in seen:
		out.append(id)
	return out

func path(from: Vector3, to: Vector3) -> Array[Vector3]:
	var from_room := room_at(from)
	var to_room := room_at(to)
	if from_room == "" or to_room == "" or from_room == to_room:
		return [to]

	var prev := {from_room: ""}
	var prev_edge := {}
	var queue: Array[String] = [from_room]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur == to_room:
			break
		for e in edges.get(cur, []):
			if not _is_open(e.door) or prev.has(e.room):
				continue
			prev[e.room] = cur
			prev_edge[e.room] = e
			queue.append(e.room)

	if not prev.has(to_room):
		return []

	var chain: Array[Vector3] = []
	var cur := to_room
	while cur != from_room:
		var e: Dictionary = prev_edge[cur]
		chain.push_front(e.point)
		cur = prev[cur]
	chain.append(to)
	return chain

func _build_edges() -> void:
	for d in map.doors:
		var off := Vector3(0.35, 0, 0) if d.size.x <= d.size.z else Vector3(0, 0, 0.35)
		var ra := room_at(d.position + off)
		var rb := room_at(d.position - off)
		if ra == "" and rb != "":
			ra = d.room
		if rb == "" and ra != "":
			rb = d.room
		if ra == "" or rb == "" or ra == rb:
			continue
		_add_edge(ra, rb, d.id, d.position)
		_add_edge(rb, ra, d.id, d.position)

func _add_edge(a: String, b: String, door_id: String, point: Vector3) -> void:
	if not edges.has(a):
		edges[a] = []
	edges[a].append({ "room": b, "door": door_id, "point": point })

func _is_open(door_id: String) -> bool:
	var door: DoorState = doors.get(door_id, null)
	return door != null and door.open

func _contains(rect: Rect2, p: Vector2) -> bool:
	return p.x >= rect.position.x - 0.05 and p.x <= rect.end.x + 0.05 \
		and p.y >= rect.position.y - 0.05 and p.y <= rect.end.y + 0.05
