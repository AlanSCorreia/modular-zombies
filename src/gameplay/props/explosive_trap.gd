class_name ExplosiveTrap
extends StaticBody3D

## Trap de proximidade: area 2|4 dispara, corpo 16 permite tiro e cadeia.

const TRAP_SCENE := preload("res://assets/models/props/trap/trap.glb")

var data: ExplosiveData
var trap_data: TrapData
var area: Area3D
var detonated := false

func setup(p_data: ExplosiveData, p_trap: TrapData, pos: Vector3) -> void:
	data = p_data
	trap_data = p_trap
	position = pos
	collision_layer = 16 | 32
	collision_mask = 0
	add_to_group("explosive_chain")

	var model := TRAP_SCENE.instantiate()
	add_child(model)

	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.45, 0.12, 0.45)
	cs.shape = box
	add_child(cs)

	area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 2 | 4
	area.monitoring = true
	var acs := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = p_trap.trigger_radius if trap_data != null else 1.3
	acs.shape = sphere
	area.add_child(acs)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

func _on_body_entered(body: Node) -> void:
	if detonated:
		return
	if body is CharacterBody3D:
		detonate(0)

func hit(_damage: float) -> void:
	detonate(0)

func detonate(depth: int = 0) -> void:
	if detonated or data == null:
		return
	detonated = true
	ExplosionSystem.explode(get_world_3d(), get_tree(), global_position, data, depth, self)
	queue_free()
