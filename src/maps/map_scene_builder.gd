class_name MapSceneBuilder
extends RefCounted

## Carrega a geometria autoral do mapa (GLB/.tscn) e cria apenas
## colisão, áreas de interação e labels a partir do JSON.

var map: MapData
var root: Node3D
var map_root: Node3D
var ctx: MapContext
var explosives: Dictionary = {}

func build(parent: Node3D, data: MapData, p_explosives: Dictionary = {}) -> MapContext:
	root = parent
	map = data
	explosives = p_explosives
	ctx = MapContext.new()
	ctx.spawns = data.zombie_spawns.duplicate()

	var packed: PackedScene = load(data.scene)
	if packed == null:
		push_error("Cena do mapa não encontrada: " + data.scene)
		return ctx

	map_root = packed.instantiate() as Node3D
	if map_root == null:
		push_error("Cena do mapa não é Node3D: " + data.scene)
		return ctx
	map_root.name = "MapGeometry"
	root.add_child(map_root)

	_build_collision(map_root)
	_build_doors()
	_build_wallbuys()
	_build_perks()
	_build_box()
	_build_barricades()
	_build_barrels()
	_build_traps()
	_build_radios()
	_collect_lights()
	return ctx

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
		var door := DoorState.new()
		door.id = d.id
		door.name = d.name
		door.cost = d.cost
		door.room = d.room
		door.data = d
		door.node = node
		door.body = body
		door.label = _label(node, "%s\n%d" % [d.name, d.cost], Vector3(0, 0.25, 0), 54)
		if body != null:
			body.set_meta("interact", door)
		ctx.doors[d.id] = door

func _build_wallbuys() -> void:
	for wb in map.wallbuys:
		var holder := map_root.find_child("WallBuy_" + wb.id, true, false) as Node3D
		if holder == null:
			push_warning("Wallbuy sem geometria: " + wb.id)
			continue
		var item := Interactable.new()
		item.kind = Interactable.Kind.WALLBUY
		item.id = wb.id
		item.name = wb.name
		item.cost = wb.cost
		item.weapon_id = wb.weapon_id
		item.node = holder
		item.label = _label(holder, "%s\n%d" % [wb.name, wb.cost], Vector3(0, -0.52, 0.04), 46)
		item.area = _area(holder, Vector3(0, 0.1, 0.55), Vector3(1.7, 1.8, 1.1), item)
		ctx.wallbuys[wb.id] = item

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
		var item := Interactable.new()
		item.kind = Interactable.Kind.PERK
		item.id = p.id
		item.name = p.name
		item.cost = p.cost
		item.effect = p.effect
		item.node = holder
		item.label = _label(holder, "%s\n%d" % [p.name, p.cost], Vector3(0, 0.62, 0.36), 40, col)
		item.area = _area(holder, Vector3(0, 0.9, 0.85), Vector3(1.8, 2.0, 1.3), item)
		ctx.perks[p.id] = item

func _build_box() -> void:
	if map.box == null:
		return
	var holder := map_root.find_child("Box", true, false) as Node3D
	if holder == null:
		push_warning("Caixa sem geometria")
		return
	var b := BoxState.new()
	b.id = "box"
	b.name = "CAIXA MISTERIOSA"
	b.cost = map.box.cost
	b.data = map.box
	b.node = holder
	b.lid = holder.get_node_or_null("Lid")
	b.label = _label(holder, "?", Vector3(0, 0.62, 0.52), 120, Color(0.25, 0.85, 0.95))
	b.area = _area(holder, Vector3(0, 0.6, 0.85), Vector3(2.0, 1.6, 1.4), b)
	ctx.box = b

func _build_barricades() -> void:
	for data in map.barricades:
		var holder := map_root.find_child("Barricade_" + data.id, true, false) as Node3D
		if holder == null:
			push_warning("Barricada sem geometria: " + data.id)
			continue
		var planks: Array[MeshInstance3D] = []
		for child in holder.get_children():
			if child is MeshInstance3D and String(child.name).begins_with("Plank"):
				planks.append(child)
		planks.sort_custom(func(a: MeshInstance3D, b: MeshInstance3D) -> bool:
			return String(a.name).get_slice("_", 1).to_int() \
				< String(b.name).get_slice("_", 1).to_int()
		)
		var b := BarricadeState.new()
		b.id = data.id
		b.name = data.id
		b.data = data
		b.node = holder
		b.planks = planks
		b.area = _area(holder, Vector3.ZERO, Vector3(2.4, 1.8, 1.6), b)
		b.setup_runtime()
		ctx.barricades[data.id] = b

func _build_barrels() -> void:
	for barr in map.barrels:
		var data: ExplosiveData = explosives.get(barr.explosive_id, null)
		if data == null:
			push_warning("Barril sem explosivo: " + barr.id)
			continue
		var b := ExplosiveBarrel.new()
		b.name = "Barrel_" + barr.id
		b.setup(data, barr.position)
		root.add_child(b)
		ctx.barrels[barr.id] = b

func _build_traps() -> void:
	for trap in map.traps:
		var data: ExplosiveData = explosives.get(trap.explosive_id, null)
		if data == null:
			push_warning("Trap sem explosivo: " + trap.id)
			continue
		var t := ExplosiveTrap.new()
		t.name = "Trap_" + trap.id
		t.setup(data, trap, trap.position)
		root.add_child(t)
		ctx.traps[trap.id] = t

func _build_radios() -> void:
	var scene: PackedScene = load("res://assets/models/props/radio/radio.glb")
	for radio in map.radios:
		var holder := Node3D.new()
		holder.name = "Radio_" + radio.id
		holder.position = radio.position
		holder.rotation.y = radio.rotation_y
		root.add_child(holder)
		if scene != null:
			holder.add_child(scene.instantiate())
		var r := RadioState.new()
		r.id = radio.id
		r.name = radio.id
		r.room = radio.room
		r.data = radio
		r.node = holder
		r.label = _label(holder, "RÁDIO", Vector3(0, 0.45, 0), 34, Color(0.95, 0.72, 0.3))
		r.area = _area(holder, Vector3.ZERO, Vector3(0.8, 0.9, 0.8), r)
		ctx.radios[radio.id] = r

func _collect_lights() -> void:
	for child in map_root.find_children("*", "OmniLight3D", true, false):
		var parent := child.get_parent()
		if parent != null and String(parent.name).begins_with("Perk_"):
			continue
		ctx.lights.append(child)

func _area(parent: Node3D, pos: Vector3, size: Vector3, meta: Interactable) -> Area3D:
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
