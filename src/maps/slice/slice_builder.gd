class_name SliceBuilder
extends RefCounted

## Constrói o vertical slice: duas salas, uma porta comprável, luzes e spawns.

var map: MapData
var root: Node3D
var doors: Dictionary = {}
var lights: Array[OmniLight3D] = []
var spawns: Array[SpawnData] = []

func build(parent: Node3D, data: MapData) -> Dictionary:
	root = parent
	map = data
	spawns = data.zombie_spawns.duplicate()
	_build_rooms()
	_build_outer_walls()
	_build_shared_wall()
	_build_door()
	_build_lights()
	return { "doors": doors, "spawns": spawns, "lights": lights }

func _mat_wall() -> StandardMaterial3D:
	return MatLib.textured("concrete_wall_008", 0.30)

func _mat_floor() -> StandardMaterial3D:
	return MatLib.textured("concrete_floor_worn_001", 0.30)

func _mat_ceiling() -> StandardMaterial3D:
	return MatLib.textured("dirty_concrete", 0.30)

func _mat_metal() -> StandardMaterial3D:
	return MatLib.textured("metal_plate", 0.35)

func _box(nm: String, size: Vector3, pos: Vector3, mat: Material, collide := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.name = nm
	mi.position = pos
	root.add_child(mi)
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

func _build_rooms() -> void:
	for r in map.rooms:
		var w := r.rect.size.x
		var d := r.rect.size.y
		var cx := r.rect.position.x + w * 0.5
		var cz := r.rect.position.y + d * 0.5
		_box("Floor_" + r.id, Vector3(w, 0.3, d), Vector3(cx, -0.15, cz), _mat_floor())
		_box("Ceiling_" + r.id, Vector3(w, 0.3, d), Vector3(cx, r.height + 0.15, cz), _mat_ceiling())

func _build_outer_walls() -> void:
	var h := 3.2
	# laterais
	_box("Wall_W", Vector3(0.3, h, 12), Vector3(-6, h * 0.5, 0), _mat_wall())
	_box("Wall_E", Vector3(0.3, h, 12), Vector3(12, h * 0.5, 0), _mat_wall())
	# fundos
	_box("Wall_S", Vector3(18.3, h, 0.3), Vector3(3, h * 0.5, -6), _mat_wall())
	_box("Wall_N", Vector3(18.3, h, 0.3), Vector3(3, h * 0.5, 6), _mat_wall())

func _build_shared_wall() -> void:
	var h := 3.2
	# parede x=0 com vão central de 2.6m para a porta
	_box("Wall_Shared_S", Vector3(0.2, h, 4.7), Vector3(0, h * 0.5, -3.65), _mat_wall())
	_box("Wall_Shared_N", Vector3(0.2, h, 4.7), Vector3(0, h * 0.5, 3.65), _mat_wall())
	_box("Wall_Shared_Lintel", Vector3(0.2, h - 2.5, 2.6), Vector3(0, 2.5 + (h - 2.5) * 0.5, 0), _mat_wall())

func _build_door() -> void:
	for d in map.doors:
		var mi := _box("Door_" + d.id, d.size, d.position, _mat_metal(), true)
		var body: StaticBody3D = mi.get_child(0)
		body.set_meta("interact", {
			"kind": "door",
			"id": d.id,
			"cost": d.cost,
			"name": d.name,
			"room": d.room,
			"node": mi,
		})
		# etiqueta de preço
		var font: Font = load("res://assets/fonts/Oswald.ttf")
		var label := Label3D.new()
		label.text = "%s\n%d" % [d.name, d.cost]
		label.font = font
		label.font_size = 54
		label.pixel_size = 0.004
		label.modulate = Color(0.95, 0.68, 0.2)
		label.outline_size = 10
		label.outline_modulate = Color(0, 0, 0, 0.9)
		label.position = d.position + Vector3(-0.35, 0.25, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		root.add_child(label)
		doors[d.id] = { "data": d, "node": mi, "body": body, "label": label, "open": false }

func _build_lights() -> void:
	for p in [Vector3(-3, 2.9, 0), Vector3(6, 2.9, 0)]:
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.78, 0.52)
		l.light_energy = 3.2
		l.omni_range = 10.0
		l.position = p
		l.shadow_enabled = p.x < 0
		root.add_child(l)
		lights.append(l)
