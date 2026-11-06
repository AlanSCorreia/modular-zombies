class_name MapSceneBuilder
extends RefCounted

## Carrega a geometria autoral do mapa (GLB/.tscn) e cria apenas
## colisão, áreas de interação e labels a partir do JSON.

var map: MapData
var root: Node3D
var map_root: Node3D
var doors: Dictionary = {}
var wallbuys: Dictionary = {}
var perks: Dictionary = {}
var box: Dictionary = {}
var barricades: Dictionary = {}
var spawns: Array[SpawnData] = []
var lights: Array[OmniLight3D] = []

func build(parent: Node3D, data: MapData) -> Dictionary:
	root = parent
	map = data
	spawns = data.zombie_spawns.duplicate()

	var packed: PackedScene = load(data.scene)
	if packed == null:
		push_error("Cena do mapa não encontrada: " + data.scene)
		return _empty_context()

	map_root = packed.instantiate() as Node3D
	if map_root == null:
		push_error("Cena do mapa não é Node3D: " + data.scene)
		return _empty_context()
	map_root.name = "MapGeometry"
	root.add_child(map_root)

	_build_collision(map_root)
	_build_doors()
	_build_wallbuys()
	_build_perks()
	_build_box()
	_build_barricades()
	_collect_lights()

	return {
		"doors": doors,
		"wallbuys": wallbuys,
		"perks": perks,
		"box": box,
		"barricades": barricades,
		"spawns": spawns,
		"lights": lights,
	}

func _empty_context() -> Dictionary:
	return {
		"doors": {},
		"wallbuys": {},
		"perks": {},
		"box": {},
		"barricades": {},
		"spawns": spawns,
		"lights": lights,
	}

func _build_collision(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mi := child as MeshInstance3D
			if _should_collide(mi):
				_add_collision(mi)
		_build_collision(child)

func _should_collide(mi: MeshInstance3D) -> bool:
	var n := String(mi.name)
	if n.begins_with("Buy") or n.begins_with("PerkPanel"):
		return false
	if n.begins_with("BoxTrim") or n.begins_with("Lid") or n.begins_with("Plank"):
		return false
	return true

func _add_collision(mi: MeshInstance3D) -> StaticBody3D:
	var aabb := mi.get_aabb()
	if aabb.size.x < 0.01 or aabb.size.y < 0.01 or aabb.size.z < 0.01:
		return null
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = aabb.size
	cs.shape = shape
	cs.position = aabb.position + aabb.size * 0.5
	body.add_child(cs)
	mi.add_child(body)
	return body

func _build_doors() -> void:
	for d in map.doors:
		var node := map_root.find_child("Door_" + d.id, true, false) as MeshInstance3D
		if node == null:
			push_warning("Porta sem geometria: " + d.id)
			continue
		var body := node.get_node_or_null("Collision") as StaticBody3D
		if body == null:
			body = _add_collision(node)
		if body != null:
			body.set_meta("interact", {
				"kind": "door", "id": d.id, "cost": d.cost,
				"name": d.name, "room": d.room, "node": node,
			})
		var label := _label(node, "%s\n%d" % [d.name, d.cost], Vector3(0, 0.25, 0), 54)
		doors[d.id] = { "data": d, "node": node, "body": body, "label": label, "open": false }

func _build_wallbuys() -> void:
	for wb in map.wallbuys:
		var holder := map_root.find_child("WallBuy_" + wb.id, true, false) as Node3D
		if holder == null:
			push_warning("Wallbuy sem geometria: " + wb.id)
			continue
		_label(holder, "%s\n%d" % [wb.name, wb.cost], Vector3(0, -0.52, 0.04), 46)
		var area := _area(holder, Vector3(0, 0.1, 0.55), Vector3(1.7, 1.8, 1.1), {
			"kind": "wallbuy", "id": wb.id, "weapon": wb.weapon_id,
			"cost": wb.cost, "name": wb.name,
		})
		wallbuys[wb.id] = { "data": wb, "node": holder, "area": area }

func _build_perks() -> void:
	for p in map.perks:
		var holder := map_root.find_child("Perk_" + p.id, true, false) as Node3D
		if holder == null:
			push_warning("Perk sem geometria: " + p.id)
			continue
		var col := Color(0.9, 0.18, 0.12)
		if p.effect == "speed":
			col = Color(0.2, 0.85, 0.35)
		elif p.effect == "tap":
			col = Color(0.95, 0.65, 0.12)
		_label(holder, "%s\n%d" % [p.name, p.cost], Vector3(0, 0.62, 0.36), 40, col)
		var area := _area(holder, Vector3(0, 0.9, 0.85), Vector3(1.8, 2.0, 1.3), {
			"kind": "perk", "id": p.id, "cost": p.cost, "name": p.name,
			"effect": p.effect,
		})
		perks[p.id] = { "data": p, "node": holder, "area": area }

func _build_box() -> void:
	if map.box == null:
		return
	var holder := map_root.find_child("Box", true, false) as Node3D
	if holder == null:
		push_warning("Caixa sem geometria")
		return
	var lid := holder.get_node_or_null("Lid")
	_label(holder, "?", Vector3(0, 0.62, 0.52), 120, Color(0.25, 0.85, 0.95))
	var area := _area(holder, Vector3(0, 0.6, 0.85), Vector3(2.0, 1.6, 1.4), {
		"kind": "box", "id": "box", "cost": map.box.cost, "name": "CAIXA MISTERIOSA",
	})
	box = { "data": map.box, "node": holder, "lid": lid, "area": area }

func _build_barricades() -> void:
	for b in map.barricades:
		var holder := map_root.find_child("Barricade_" + b.id, true, false) as Node3D
		if holder == null:
			push_warning("Barricada sem geometria: " + b.id)
			continue
		var planks: Array[MeshInstance3D] = []
		for child in holder.get_children():
			if child is MeshInstance3D and String(child.name).begins_with("Plank"):
				planks.append(child)
		barricades[b.id] = { "data": b, "node": holder, "planks": planks }

func _collect_lights() -> void:
	for child in map_root.get_children():
		if child is OmniLight3D:
			lights.append(child)

func _area(parent: Node3D, pos: Vector3, size: Vector3, meta: Dictionary) -> Area3D:
	var a := Area3D.new()
	a.position = pos
	a.collision_layer = 8
	a.collision_mask = 0
	a.monitoring = false
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	a.add_child(cs)
	a.set_meta("interact", meta)
	parent.add_child(a)
	return a

func _label(parent: Node3D, text: String, pos: Vector3, size := 46, color := Color(0.95, 0.68, 0.2)) -> Label3D:
	var font: Font = load("res://assets/fonts/Oswald.ttf")
	var l := Label3D.new()
	l.text = text
	l.font = font
	l.font_size = size
	l.pixel_size = 0.004
	l.modulate = color
	l.outline_size = 10
	l.outline_modulate = Color(0, 0, 0, 0.9)
	l.position = pos
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	parent.add_child(l)
	return l
