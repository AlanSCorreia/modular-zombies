extends SceneTree

func _init() -> void:
	var ok := true
	MapArgs.clear_playtest_override()

	ok = ok and MapArgs.map_id_from_args(["--map", "map.bunker13"]) == "map.bunker13"
	ok = ok and MapArgs.map_id_from_args([]) == MapArgs.DEFAULT_MAP

	ok = ok and MapArgs.set_playtest_override("map.slice")
	ok = ok and MapArgs.map_id_from_args([]) == "map.slice"
	ok = ok and not FileAccess.file_exists(MapArgs.OVERRIDE_PATH)
	ok = ok and MapArgs.map_id_from_args([]) == MapArgs.DEFAULT_MAP

	MapArgs.set_playtest_override("map.bunker13")
	ok = ok and MapArgs.map_id_from_args(["--map", "map.slice"]) == "map.slice"
	MapArgs.clear_playtest_override()

	if ok:
		print("PLAYTEST_OK args_priority=true override_one_shot=true")
		quit(0)
	else:
		printerr("PLAYTEST_FAIL")
		quit(1)
