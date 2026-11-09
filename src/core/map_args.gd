class_name MapArgs
extends RefCounted

## Parsing de argumentos de mapa, isolado do GameRoot para ser testável
## sem depender dos autoloads da cena principal.

const DEFAULT_MAP := "map.slice"
const OVERRIDE_PATH := "user://playtest.cfg"

static func map_id_from_args(args: PackedStringArray) -> String:
	var override := _consume_override()
	var i := args.find("--map")
	if i >= 0 and i + 1 < args.size():
		return args[i + 1]
	if override != "":
		return override
	return DEFAULT_MAP

static func set_playtest_override(map_id: String) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("playtest", "map", map_id)
	return cfg.save(OVERRIDE_PATH) == OK

static func clear_playtest_override() -> void:
	if FileAccess.file_exists(OVERRIDE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(OVERRIDE_PATH))

static func _consume_override() -> String:
	if not FileAccess.file_exists(OVERRIDE_PATH):
		return ""
	var cfg := ConfigFile.new()
	if cfg.load(OVERRIDE_PATH) != OK:
		clear_playtest_override()
		return ""
	var map_id := String(cfg.get_value("playtest", "map", ""))
	clear_playtest_override()
	return map_id
