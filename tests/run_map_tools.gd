extends SceneTree

const OUT_DIR := "res://tests/tmp_maps"

func _init() -> void:
	var ok := true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var created := MapTools.create_from_template("map.tmp_tool", "Mapa Teste", OUT_DIR)
	ok = ok and created.get("ok", false)
	var created_data := _read(String(created.get("path", "")))
	ok = ok and not created_data.is_empty()
	ok = ok and String(created_data.get("id", "")) == "map.tmp_tool"
	ok = ok and String(created_data.get("name", "")) == "Mapa Teste"
	ok = ok and String(created_data.get("builder", "")) == "scene"

	var dup := MapTools.duplicate_map(
		"map.slice", "map.tmp_dup", "Duplicado", OUT_DIR,
		"res://content/maps"
	)
	ok = ok and dup.get("ok", false)
	var dup_data := _read(String(dup.get("path", "")))
	ok = ok and String(dup_data.get("id", "")) == "map.tmp_dup"
	ok = ok and String(dup_data.get("name", "")) == "Duplicado"

	var blocked := MapTools.create_from_template("map.tmp_tool", "Outro", OUT_DIR)
	ok = ok and not blocked.get("ok", true)

	for path in [created.get("path", ""), dup.get("path", "")]:
		if path != "" and FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(OUT_DIR))

	if ok:
		print("TOOLS_OK create=%s duplicate=%s" % [
			created.get("id", ""), dup.get("id", ""),
		])
		quit(0)
	else:
		printerr("TOOLS_FAIL")
		quit(1)

func _read(path: String) -> Dictionary:
	if path == "" or not FileAccess.file_exists(path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}
