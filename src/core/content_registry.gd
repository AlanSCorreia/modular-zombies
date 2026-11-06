extends Node

## Registro de conteúdo: carrega e valida .tres de mapas, armas, inimigos e perks.

const ROOTS := {
	"maps": "res://content/maps",
	"weapons": "res://content/weapons",
	"enemies": "res://content/enemies",
	"perks": "res://content/perks",
	"quests": "res://content/quests",
}

var maps: Dictionary = {}
var weapons: Dictionary = {}
var enemies: Dictionary = {}
var perks: Dictionary = {}
var quests: Dictionary = {}

func _ready() -> void:
	reload()

func reload() -> void:
	maps.clear()
	weapons.clear()
	enemies.clear()
	perks.clear()
	quests.clear()
	for kind in ROOTS.keys():
		var root: String = ROOTS[kind]
		for path in _scan(root):
			var res := load(path)
			if res == null or not ("id" in res):
				continue
			match kind:
				"maps": maps[res.id] = res
				"weapons": weapons[res.id] = res
				"enemies": enemies[res.id] = res
				"perks": perks[res.id] = res
				"quests": quests[res.id] = res

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
		elif f.ends_with(".tres"):
			out.append(p)
		f = da.get_next()
	da.list_dir_end()
	return out

func get_map(id: String):
	return maps.get(id, null)

func get_weapon(id: String):
	return weapons.get(id, null)

func get_enemy(id: String):
	return enemies.get(id, null)

func get_perk(id: String):
	return perks.get(id, null)

func get_quest(id: String):
	return quests.get(id, null)
