extends Node
class_name ContentRegistry

## Carrega todo o conteúdo JSON e valida. Nada de .tres de conteúdo.

const ROOT := "res://content"

var maps: Dictionary = {}
var weapons: Dictionary = {}
var enemies: Dictionary = {}
var melees: Dictionary = {}
var explosives: Dictionary = {}
var errors: Array[String] = []
var loaded := false

func _ready() -> void:
	reload()

func reload() -> void:
	maps.clear()
	weapons.clear()
	enemies.clear()
	melees.clear()
	explosives.clear()
	errors.clear()
	loaded = false
	for path in _scan(ROOT):
		var text := FileAccess.get_file_as_string(path)
		if text == "":
			errors.append("%s: arquivo vazio/ilegível" % path)
			continue
		var parsed = JSON.parse_string(text)
		if typeof(parsed) != TYPE_DICTIONARY:
			errors.append("%s: JSON inválido" % path)
			continue
		var d: Dictionary = parsed
		var kind := String(d.get("kind", ""))
		var id := String(d.get("id", ""))
		if id == "":
			errors.append("%s: id ausente" % path)
			continue
		match kind:
			"map":
				maps[id] = MapData.from_dict(d)
			"weapon":
				weapons[id] = WeaponData.from_dict(d)
			"enemy":
				enemies[id] = EnemyData.from_dict(d)
			"melee":
				melees[id] = MeleeData.from_dict(d)
			"explosive":
				explosives[id] = ExplosiveData.from_dict(d)
			_:
				errors.append("%s: kind desconhecido '%s'" % [path, kind])
	errors.append_array(ContentValidator.validate(maps, weapons, enemies, melees, explosives))
	for e in errors:
		push_error("CONTEÚDO: " + e)
	loaded = errors.is_empty()
	print("CONTENT_LOADED maps=%d weapons=%d enemies=%d melees=%d explosives=%d errors=%d" % [
		maps.size(), weapons.size(), enemies.size(), melees.size(), explosives.size(), errors.size(),
	])

func _scan(dir: String) -> Array[String]:
	var out: Array[String] = []
	var da := DirAccess.open(dir)
	if da == null:
		return out
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		var p := dir.path_join(f)
		if da.current_is_dir():
			out.append_array(_scan(p))
		elif f.ends_with(".json"):
			out.append(p)
		f = da.get_next()
	da.list_dir_end()
	return out

func get_map(id: String) -> MapData:
	return maps.get(id, null)

func get_weapon(id: String) -> WeaponData:
	return weapons.get(id, null)

func get_enemy(id: String) -> EnemyData:
	return enemies.get(id, null)

func get_melee(id: String) -> MeleeData:
	return melees.get(id, null)

func get_explosive(id: String) -> ExplosiveData:
	return explosives.get(id, null)
