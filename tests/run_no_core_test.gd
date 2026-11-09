extends SceneTree

## Garante que o núcleo não conhece IDs específicos de mapa/arma/inimigo.

const ROOTS := ["res://src/gameplay", "res://src/maps"]
const PATTERN := "\"(?:map|weapon|enemy)\\.[a-z0-9_]+"

func _init() -> void:
	var re := RegEx.new()
	re.compile(PATTERN)
	var hits: Array[String] = []
	var visited := [0]
	for root in ROOTS:
		_scan(root, re, hits, visited)
	if visited[0] == 0:
		printerr("NO_CORE_FAIL nenhum .gd escaneado")
		quit(1)
		return
	if hits.is_empty():
		print("NO_CORE_OK")
		quit(0)
	else:
		for hit in hits:
			printerr("NO_CORE_FAIL ", hit)
		quit(1)

func _scan(path: String, re: RegEx, hits: Array[String], visited: Array) -> void:
	var da := DirAccess.open(path)
	if da == null:
		printerr("NO_CORE_FAIL diretório inacessível: ", path)
		visited[0] = -1
		return
	da.list_dir_begin()
	var name := da.get_next()
	while name != "":
		if name == "legacy" or name.begins_with("."):
			name = da.get_next()
			continue
		var full := path.path_join(name)
		if da.current_is_dir():
			_scan(full, re, hits, visited)
		elif name.ends_with(".gd"):
			visited[0] += 1
			var text := FileAccess.get_file_as_string(full)
			for m in re.search_all(text):
				hits.append("%s: %s" % [full, m.get_string()])
		name = da.get_next()
	da.list_dir_end()
