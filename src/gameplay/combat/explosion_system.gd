class_name ExplosionSystem
extends RefCounted

## Explosão com raio, falloff, LOS, impulso e cadeia limitada.
## Camadas: 1 = mundo, 4 = zumbis, 16 = props explosivos.

static var _fx_mesh: QuadMesh
static var _fx_mat: StandardMaterial3D

static func _ensure_fx() -> void:
	if _fx_mesh != null:
		return
	_fx_mesh = QuadMesh.new()
	_fx_mesh.size = Vector2(0.55, 0.55)
	_fx_mat = StandardMaterial3D.new()
	_fx_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_fx_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_fx_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_fx_mat.albedo_texture = MatLib.smoke_texture()
	_fx_mat.albedo_color = Color(1.0, 0.62, 0.28, 1.0)
	_fx_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED

static func _spawn_fx(tree: SceneTree, pos: Vector3, radius: float) -> void:
	_ensure_fx()
	var root := Node3D.new()
	root.name = "ExplosionFX"
	root.position = pos
	root.add_to_group("explosion_fx")
	var parent := tree.current_scene
	if parent == null:
		parent = tree.root
	parent.add_child(root)

	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.62, 0.28)
	light.light_energy = 3.2
	light.omni_range = maxf(radius * 1.6, 2.0)
	root.add_child(light)
	var tw := tree.create_tween()
	tw.tween_property(light, "light_energy", 0.0, 0.32)

	var particles := CPUParticles3D.new()
	particles.amount = 28
	particles.lifetime = 0.55
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.6
	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.gravity = Vector3(0, -3.0, 0)
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 6.0
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 1.4
	particles.color = Color(1.0, 0.58, 0.24, 1.0)
	particles.mesh = _fx_mesh
	particles.material_override = _fx_mat
	root.add_child(particles)
	particles.emitting = true

	tree.create_timer(1.0, false).timeout.connect(root.queue_free)
	var sfx := tree.root.get_node_or_null("Sfx")
	if sfx != null and sfx.has_method("play_3d"):
		sfx.play_3d("explosion", pos, -2, 0.68, 0.12)

static func explode(world: World3D, tree: SceneTree, pos: Vector3, data: ExplosiveData,
		depth: int = 0, source: Node = null) -> int:
	if world == null or tree == null or data == null:
		return 0

	var shape := SphereShape3D.new()
	shape.radius = data.radius
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), pos)
	q.collision_mask = 4 | 16
	q.collide_with_bodies = true
	q.collide_with_areas = false
	var hits := world.direct_space_state.intersect_shape(q, data.max_targets)

	var count := 0
	for hit in hits:
		var col = hit.collider
		if col == null or col == source:
			continue
		var target_pos: Vector3 = col.global_position
		var dist := pos.distance_to(target_pos)
		if dist > data.radius:
			continue
		if dist > 0.2:
			var ray := PhysicsRayQueryParameters3D.create(pos, target_pos, 1)
			var blocked := world.direct_space_state.intersect_ray(ray)
			if not blocked.is_empty() and blocked.get("position", target_pos).distance_to(target_pos) > 0.25:
				continue

		var t := clampf(dist / maxf(data.radius, 0.001), 0.0, 1.0)
		var mult := lerpf(1.0, data.falloff, t)
		if col.has_method("take_damage"):
			col.take_damage(data.damage * mult, false, target_pos)
			count += 1
		elif col is RigidBody3D:
			var rb: RigidBody3D = col
			var dir := (target_pos - pos).normalized()
			rb.apply_impulse(dir * data.impulse * mult, target_pos - rb.global_position)
			count += 1

	if depth < data.chain_depth:
		for n in tree.get_nodes_in_group("explosive_chain"):
			if n == source or not n is Node3D or not n.has_method("detonate"):
				continue
			if n.global_position.distance_to(pos) <= data.radius:
				n.detonate(depth + 1)
	_spawn_fx(tree, pos, data.radius)
	return count
