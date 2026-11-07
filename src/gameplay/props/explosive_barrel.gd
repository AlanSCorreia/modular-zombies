class_name ExplosiveBarrel
extends StaticBody3D

const BARREL_SCENE := preload("res://assets/models/props/barrel/barrel.glb")

var data: ExplosiveData
var detonated := false

func setup(p_data: ExplosiveData, pos: Vector3) -> void:
	data = p_data
	position = pos
	collision_layer = 16
	collision_mask = 0
	add_to_group("explosive_chain")

	var model := BARREL_SCENE.instantiate()
	add_child(model)

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.8, 1.1, 0.8)
	cs.shape = shape
	add_child(cs)

func hit(_damage: float) -> void:
	detonate(0)

func detonate(depth: int) -> void:
	if detonated or data == null:
		return
	detonated = true
	ExplosionSystem.explode(get_world_3d(), get_tree(), global_position, data, depth, self)
	queue_free()
