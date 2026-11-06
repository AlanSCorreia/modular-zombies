extends SceneTree

var failures := 0

func check(cond: bool, name: String) -> void:
	if cond:
		print("PASS  ", name)
	else:
		failures += 1
		printerr("FAIL  ", name)

func _init() -> void:
	var reg := ContentRegistry.new()
	reg.reload()
	var map: MapData = reg.get_map("map.bunker13")
	check(map != null, "mapa bunker13")
	if map == null:
		reg.free()
		quit(1)
		return
	var root := Node3D.new()
	get_root().add_child(root)
	var ctx := Bunker13Builder.new().build(root, map)
	check(ctx.doors.size() == 4, "4 portas")
	check(ctx.wallbuys.size() == 4, "4 wallbuys")
	check(ctx.perks.size() == 3, "3 perks")
	check(not ctx.box.is_empty(), "caixa misteriosa")
	check(ctx.barricades.size() == 9, "9 barricadas")
	check(ctx.spawns.size() == 9, "9 spawns")
	check(ctx.lights.size() == 8, "8 luzes")
	check(root.get_child_count() > 20, "geometria construída")
	root.free()
	reg.free()
	if failures > 0:
		printerr("BUNKER13_FAIL %d" % failures)
		quit(1)
		return
	print("BUNKER13_OK")
	quit(0)
