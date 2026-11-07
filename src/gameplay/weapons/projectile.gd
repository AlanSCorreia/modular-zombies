class_name Projectile
extends Node3D

static var _sphere: SphereMesh
static var _material: StandardMaterial3D

var data: WeaponData
var player: PlayerController
var speed := 24.0
var damage := 100.0
var radius := 0.22
var lifetime := 4.0
var explosion_radius := 0.0
var _dir := Vector3.FORWARD
var _life := 4.0

func setup(p_data: WeaponData, from: Vector3, dir: Vector3, p_player: PlayerController) -> void:
	data = p_data
	player = p_player
	position = from
	_dir = dir.normalized()
	speed = float(data.projectile.get("speed", 24.0))
	damage = float(data.stats.get("damage", 100.0))
	radius = float(data.projectile.get("radius", 0.22))
	lifetime = float(data.projectile.get("lifetime", 4.0))
	explosion_radius = float(data.projectile.get("explosion_radius", 0.0))
	_life = lifetime

	if _sphere == null:
		_sphere = SphereMesh.new()
		_sphere.radius = 0.5
		_sphere.height = 1.0
	if _material == null:
		_material = MatLib.emissive(Color(0.35, 0.85, 1.0), 3.0)
	var mi := MeshInstance3D.new()
	mi.mesh = _sphere
	mi.material_override = _material
	mi.scale = Vector3.ONE * (radius * 2.0)
	add_child(mi)

func _physics_process(delta: float) -> void:
	var next := global_position + _dir * speed * delta
	var q := PhysicsRayQueryParameters3D.create(global_position, next, 1 | 4 | 16)
	q.collide_with_areas = false
	var res: Dictionary = get_world_3d().direct_space_state.intersect_ray(q)
	if not res.is_empty():
		var col = res.collider
		if col is ZombieEnemy:
			var z: ZombieEnemy = col
			z.take_damage(damage, false, res.position)
			Events.hitmarker.emit()
		elif col is ExplosiveBarrel:
			var barrel: ExplosiveBarrel = col
			barrel.hit(damage)
		_explode(res.position)
		queue_free()
		return

	global_position = next
	_life -= delta
	if _life <= 0.0:
		_explode(global_position)
		queue_free()

func _explode(pos: Vector3) -> void:
	var ed: ExplosiveData = null
	if data.explosive != "":
		ed = Content.get_explosive(data.explosive)
	if ed == null and explosion_radius > 0.0:
		ed = ExplosiveData.new()
		ed.id = "runtime"
		ed.name = "EXPLOSÃO"
		ed.damage = damage * 0.6
		ed.radius = explosion_radius
		ed.falloff = 0.35
		ed.impulse = 4.0
		ed.max_targets = 16
		ed.chain_depth = 0
	if ed != null:
		ExplosionSystem.explode(get_world_3d(), get_tree(), pos, ed, 0)
