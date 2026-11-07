class_name Grenade
extends RigidBody3D

var data: ExplosiveData
var _fuse := 2.5
var _armed := true

func setup(p_data: ExplosiveData, from: Vector3, dir: Vector3, throw_speed := 9.0) -> void:
	data = p_data
	_fuse = data.fuse
	position = from
	collision_layer = 16
	collision_mask = 1 | 16
	gravity_scale = 1.0
	linear_velocity = dir.normalized() * throw_speed + Vector3.UP * 2.5
	angular_velocity = Vector3(randf_range(-6, 6), randf_range(-6, 6), randf_range(-6, 6))

	var packed: PackedScene = load("res://assets/models/props/grenade/grenade.glb")
	if packed != null:
		add_child(packed.instantiate())

	var cs := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.12
	cs.shape = shape
	add_child(cs)

func _physics_process(delta: float) -> void:
	if not _armed:
		return
	_fuse -= delta
	if _fuse <= 0.0:
		_explode()

func _explode() -> void:
	_armed = false
	ExplosionSystem.explode(get_world_3d(), get_tree(), global_position, data, 0)
	queue_free()
