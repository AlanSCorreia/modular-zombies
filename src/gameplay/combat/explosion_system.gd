class_name ExplosionSystem
extends RefCounted

## Explosão com raio, falloff, LOS, impulso e cadeia limitada.
## Camadas: 1 = mundo, 4 = zumbis, 16 = props explosivos.

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
	return count
