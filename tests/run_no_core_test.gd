extends SceneTree

## Garante que o núcleo não conhece IDs específicos de mapa/arma/inimigo.

const ROOTS := ["res://src/gameplay", "res://src/maps"]
const PATTERN := "\"(?:map|weapon|enemy)\\.[a-z0-9_]+"

func _init() -> void:
	var re := RegEx.new()
	re.compile(PATTERN)
	var hits: Array[String] = []
	for root in ROOTS:
		_scan(root, re, hits)
	if hits.is_empty():
		print("NO_CORE_OK")
		quit(0)
	else:
		for hit in hits:
			printerr("NO_CORE_FAIL ", hit)
		quit(1)

func _scan(path: String, re: RegEx, hits: Array[String]) -> void:
	var da := DirAccess.open(path)
	if da == null:
		return
	da.list_dir_begin()
	var name := da.get_next()
	while name != "":
		if name == "legacy" or name.begins_with("."):
			name = da.get_next()
			continue
		var full := path.path_join(name)
		if da.current_is_dir():
			_scan(full, re, hits)
		elif name.ends_with(".gd"):
			var text := FileAccess.get_file_as_string(full)
			for m in re.search_all(text):
				hits.append("%s: %s" % [full, m.get_string()])
		name = da.get_next()
	da.list_dir_end()
