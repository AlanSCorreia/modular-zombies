class_name Bunker13Builder
extends RefCounted

## Constrói o Bunker 13 completo a partir de MapData (JSON).
## Geometria base + portas + wallbuys + perks + caixa + barricadas.

var map: MapData
var root: Node3D
var doors: Dictionary = {}
var wallbuys: Dictionary = {}
var perks: Dictionary = {}
var box: Dictionary = {}
var barricades: Dictionary = {}
var lights: Array[OmniLight3D] = []
var spawns: Array[SpawnData] = []

func build(parent: Node3D, data: MapData) -> Dictionary:
	root = parent
	map = data
	spawns = data.zombie_spawns.duplicate()
	_build_rooms()
	_build_perimeter()
	_build_shared_walls()
	_build_doors()
	_build_wallbuys()
	_build_perks()
	_build_box()
	_build_barricades()
	_build_lights()
	return {
		"doors": doors, "wallbuys": wallbuys, "perks": perks,
		"box": box, "barricades": barricades, "spawns": spawns, "lights": lights,
	}

# ---------------------------------------------------------------- helpers

func _mat_wall() -> StandardMaterial3D:
	return MatLib.textured("concrete_wall_008", 0.30)

func _mat_brick() -> StandardMaterial3D:
	return MatLib.textured("brick_wall_001", 0.38)

func _mat_floor() -> StandardMaterial3D:
	return MatLib.textured("concrete_floor_worn_001", 0.30)

func _mat_ceiling() -> StandardMaterial3D:
	return MatLib.textured("dirty_concrete", 0.30)

func _mat_metal() -> StandardMaterial3D:
	return MatLib.textured("metal_plate", 0.35)

func _mat_wood() -> StandardMaterial3D:
	return MatLib.textured("wood_planks", 0.55)

func _box(parent: Node3D, nm: String, size: Vector3, pos: Vector3, mat: Material, collide := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.name = nm
	mi.position = pos
	parent.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = size
		cs.shape = sh
		body.add_child(cs)
		mi.add_child(body)
	return mi

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

func _wall_z(z: float, x1: float, x2: float, openings: Array = []) -> void:
	var cursor := x1
	for op in openings:
		var cx: float = op[0]
		var w: float = op[1]
		var a := cx - w * 0.5
		if a - cursor > 0.05:
			_box(root, "Wall", Vector3(a - cursor, 3.4, 0.3), Vector3((cursor + a) * 0.5, 1.7, z), _mat_wall())
		_box(root, "Lintel", Vector3(w, 0.9, 0.3), Vector3(cx, 2.95, z), _mat_wall())
		cursor = cx + w * 0.5
	if x2 - cursor > 0.05:
		_box(root, "Wall", Vector3(x2 - cursor, 3.4, 0.3), Vector3((cursor + x2) * 0.5, 1.7, z), _mat_wall())

func _wall_x(x: float, z1: float, z2: float, openings: Array = []) -> void:
	var cursor := z1
	for op in openings:
		var cz: float = op[0]
		var w: float = op[1]
		var a := cz - w * 0.5
		if a - cursor > 0.05:
			_box(root, "Wall", Vector3(0.3, 3.4, a - cursor), Vector3(x, 1.7, (cursor + a) * 0.5), _mat_wall())
		_box(root, "Lintel", Vector3(0.3, 0.9, w), Vector3(x, 2.95, cz), _mat_wall())
		cursor = cz + w * 0.5
	if z2 - cursor > 0.05:
		_box(root, "Wall", Vector3(0.3, 3.4, z2 - cursor), Vector3(x, 1.7, (cursor + z2) * 0.5), _mat_wall())

# ---------------------------------------------------------------- mapa

func _build_rooms() -> void:
	for r in map.rooms:
		var w := r.rect.size.x
		var d := r.rect.size.y
		var cx := r.rect.position.x + w * 0.5
		var cz := r.rect.position.y + d * 0.5
		_box(root, "Floor_" + r.id, Vector3(w, 0.3, d), Vector3(cx, -0.15, cz), _mat_floor())
		_box(root, "Ceiling_" + r.id, Vector3(w, 0.3, d), Vector3(cx, r.height + 0.15, cz), _mat_ceiling())

func _build_perimeter() -> void:
	_box(root, "Wall_W", Vector3(0.3, 3.4, 25), Vector3(-9, 1.7, 4.5), _mat_brick())
	_box(root, "Wall_E", Vector3(0.3, 3.4, 25), Vector3(24, 1.7, 4.5), _mat_brick())
	_box(root, "Wall_S", Vector3(33.3, 3.4, 0.3), Vector3(7.5, 1.7, -8), _mat_wall())
	_box(root, "Wall_N", Vector3(33.3, 3.4, 0.3), Vector3(7.5, 1.7, 17), _mat_brick())

func _build_shared_walls() -> void:
	# x=9 com portas em z=-2 (door2) e z=12 (door4)
	_wall_x(9, -8, 17, [[-2.0, 2.7], [12.0, 2.7]])
	# z=5 com portas em x=0 (door1) e x=16 (door3)
	_wall_z(5, -9, 24, [[0.0, 2.7], [16.0, 2.7]])

func _build_doors() -> void:
	for d in map.doors:
		var mi := _box(root, "Door_" + d.id, d.size, d.position, _mat_metal())
		var body: StaticBody3D = mi.get_child(0)
		body.set_meta("interact", {
			"kind": "door", "id": d.id, "cost": d.cost,
			"name": d.name, "room": d.room, "node": mi,
		})
		var l := _label(mi, "%s\n%d" % [d.name, d.cost], Vector3(0, 0.25, 0), 54)
		doors[d.id] = { "data": d, "node": mi, "body": body, "label": l, "open": false }

func _build_wallbuys() -> void:
	for wb in map.wallbuys:
		var holder := Node3D.new()
		holder.position = wb.position
		holder.rotation.y = wb.rotation_y
		root.add_child(holder)
		var m := MatLib.simple(Color(0.42, 0.38, 0.30), 0.45, 0.5)
		_box(holder, "BuyBody", Vector3(0.62, 0.12, 0.13), Vector3.ZERO, m, false)
		_box(holder, "BuyBarrel", Vector3(0.55, 0.05, 0.05), Vector3(0.42, 0.02, 0), m, false)
		_box(holder, "BuyMag", Vector3(0.13, 0.24, 0.09), Vector3(0.05, -0.17, 0), m, false)
		_label(holder, "%s\n%d" % [wb.name, wb.cost], Vector3(0, -0.52, 0.04), 46)
		var area := _area(holder, Vector3(0, 0.1, 0.55), Vector3(1.7, 1.8, 1.1), {
			"kind": "wallbuy", "id": wb.id, "weapon": wb.weapon_id,
			"cost": wb.cost, "name": wb.name,
		})
		wallbuys[wb.id] = { "data": wb, "node": holder, "area": area }

func _build_perks() -> void:
	for p in map.perks:
		var holder := Node3D.new()
		holder.position = p.position
		holder.rotation.y = p.rotation_y
		root.add_child(holder)
		var col := Color(0.9, 0.18, 0.12)
		if p.effect == "speed":
			col = Color(0.2, 0.85, 0.35)
		elif p.effect == "tap":
			col = Color(0.95, 0.65, 0.12)
		_box(holder, "PerkBody", Vector3(1.05, 2.0, 0.62), Vector3(0, 1.0, 0), MatLib.simple(Color(0.055, 0.06, 0.058), 0.65, 0.42))
		_box(holder, "PerkPanel", Vector3(0.9, 0.95, 0.04), Vector3(0, 1.25, 0.33), MatLib.emissive(col, 1.6), false)
		_label(holder, "%s\n%d" % [p.name, p.cost], Vector3(0, 0.62, 0.36), 40, col)
		var l := OmniLight3D.new()
		l.light_color = col
		l.light_energy = 0.9
		l.omni_range = 3.6
		l.position = Vector3(0, 1.3, 0.8)
		holder.add_child(l)
		var area := _area(holder, Vector3(0, 0.9, 0.85), Vector3(1.8, 2.0, 1.3), {
			"kind": "perk", "id": p.id, "cost": p.cost, "name": p.name,
			"effect": p.effect,
		})
		perks[p.id] = { "data": p, "node": holder, "area": area }

func _build_box() -> void:
	if map.box == null:
		return
	var holder := Node3D.new()
	holder.position = map.box.position
	root.add_child(holder)
	_box(holder, "BoxBase", Vector3(1.5, 0.72, 0.95), Vector3(0, 0.36, 0), _mat_wood())
	_box(holder, "BoxTrim", Vector3(1.55, 0.08, 1.0), Vector3(0, 0.72, 0), _mat_metal(), false)
	var lid := Node3D.new()
	lid.name = "Lid"
	lid.position = Vector3(0, 0.76, -0.47)
	holder.add_child(lid)
	_box(lid, "LidMesh", Vector3(1.5, 0.1, 0.95), Vector3(0, 0.05, 0.47), _mat_wood(), false)
	_label(holder, "?", Vector3(0, 0.62, 0.52), 120, Color(0.25, 0.85, 0.95))
	var area := _area(holder, Vector3(0, 0.6, 0.85), Vector3(2.0, 1.6, 1.4), {
		"kind": "box", "cost": map.box.cost, "name": "CAIXA MISTERIOSA",
	})
	box = { "data": map.box, "node": holder, "lid": lid, "area": area }

func _build_barricades() -> void:
	for b in map.barricades:
		var holder := Node3D.new()
		holder.position = b.position
		holder.rotation.y = b.rotation_y
		root.add_child(holder)
		var planks: Array[MeshInstance3D] = []
		for i in range(b.max_planks):
			var p := _box(holder, "Plank", Vector3(1.9, 0.17, 0.07),
				Vector3(randf_range(-0.1, 0.1), -0.55 + i * 0.22, 0), _mat_wood(), false)
			p.rotation.z = randf_range(-0.05, 0.05)
			planks.append(p)
		barricades[b.id] = { "data": b, "node": holder, "planks": planks }

func _build_lights() -> void:
	for p in [
		Vector3(-4.5, 2.95, 8.5), Vector3(4.5, 2.95, 14.0),
		Vector3(-4.0, 2.95, 0.0), Vector3(4.0, 2.95, -5.0),
		Vector3(12.5, 2.95, 0.5), Vector3(20.0, 2.95, -5.0),
		Vector3(12.5, 2.95, 10.0), Vector3(20.5, 2.95, 14.5),
	]:
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.78, 0.52)
		l.light_energy = 3.6
		l.omni_range = 12.0
		l.position = p
		l.shadow_enabled = p.x < 0 or p.x > 18
		root.add_child(l)
		lights.append(l)
