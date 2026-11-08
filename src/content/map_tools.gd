class_name MapTools
extends RefCounted

## Criação/duplicação de mapas JSON sem depender do editor nem de autoloads.
## Usado pelo dock `bunker_tools` e pelo teste headless `TOOLS_OK`.

const TEMPLATE_PATH := "res://templates/map/template.json"
const MAPS_DIR := "res://content/maps"
const MAP_PREFIX := "map."

static func _slug(value: String) -> String:
	var raw := value.strip_edges()
	if raw.begins_with(MAP_PREFIX):
		raw = raw.substr(MAP_PREFIX.length())
	return raw.to_snake_case()

static func _map_id(value: String) -> String:
	return MAP_PREFIX + _slug(value)

static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	return data if data is Dictionary else {}

static func _write_json(path: String, data: Dictionary) -> bool:
	var dir := path.get_base_dir()
	var err := DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(dir)
	)
	if err != OK and err != ERR_ALREADY_EXISTS:
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "  ", false) + "\n")
	file.close()
	return true

static func _prepare(new_id: String, new_name: String, out_dir: String,
		overwrite: bool) -> Dictionary:
	var slug := _slug(new_id)
	if slug == "":
		return {"ok": false, "error": "id vazio"}
	var map_id := MAP_PREFIX + slug
	var path := out_dir.path_join(slug + ".json")
	if not overwrite and FileAccess.file_exists(path):
		return {"ok": false, "error": "mapa já existe: " + path}
	return {
		"ok": true, "slug": slug, "id": map_id, "path": path,
		"name": new_name.strip_edges() if new_name.strip_edges() != "" else slug,
	}

static func create_from_template(new_id: String, new_name: String,
		out_dir := MAPS_DIR, overwrite := false) -> Dictionary:
	var info := _prepare(new_id, new_name, out_dir, overwrite)
	if not info.get("ok", false):
		return info
	var data := _read_json(TEMPLATE_PATH)
	if data.is_empty():
		return {"ok": false, "error": "template ausente: " + TEMPLATE_PATH}
	data["id"] = info["id"]
	data["name"] = info["name"]
	if not _write_json(info["path"], data):
		return {"ok": false, "error": "falha ao escrever " + info["path"]}
	return {"ok": true, "path": info["path"], "id": info["id"]}

static func duplicate_map(source_id: String, new_id: String, new_name: String,
		out_dir := MAPS_DIR, source_dir := MAPS_DIR,
		overwrite := false) -> Dictionary:
	var info := _prepare(new_id, new_name, out_dir, overwrite)
	if not info.get("ok", false):
		return info
	var source_slug := _slug(source_id)
	var source_path := source_dir.path_join(source_slug + ".json")
	var data := _read_json(source_path)
	if data.is_empty():
		return {"ok": false, "error": "mapa origem ausente: " + source_path}
	data["id"] = info["id"]
	data["name"] = info["name"]
	if not _write_json(info["path"], data):
		return {"ok": false, "error": "falha ao escrever " + info["path"]}
	return {"ok": true, "path": info["path"], "id": info["id"]}
