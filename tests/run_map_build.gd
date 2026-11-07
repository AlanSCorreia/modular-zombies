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
	check(map.builder == "scene", "Bunker 13 usa cena autoral")
	var builder = MapBuilderRegistry.create(map.builder)
	check(builder != null, "builder scene carregado")
	if builder == null:
		root.free()
		reg.free()
		quit(1)
		return
	var ctx: MapContext = builder.build(root, map, reg.explosives)
	check(ctx.doors.size() == 4, "4 portas")
	check(ctx.wallbuys.size() == 4, "4 wallbuys")
	check(ctx.perks.size() == 3, "3 perks")
	check(ctx.box != null, "caixa misteriosa")
	check(ctx.barricades.size() == 9, "9 barricadas")
	check(ctx.barrels.size() == 2, "2 barris explosivos")
	check(ctx.spawns.size() == 9, "9 spawns")
	check(ctx.lights.size() == 8, "8 luzes")
	for did in ctx.doors:
		var info: DoorState = ctx.doors[did]
		check(info.body != null, "porta %s tem colisão" % did)
		check(info.body.has_meta("interact"), "porta %s interagível" % did)
	for wid in ctx.wallbuys:
		check(ctx.wallbuys[wid].area.has_meta("interact"), "wallbuy %s interagível" % wid)
	for bid in ctx.barricades:
		var bar: BarricadeState = ctx.barricades[bid]
		check(bar.area != null and bar.area.has_meta("interact"), "barricada %s interagível" % bid)
		check(bar.plank_count == bar.data.max_planks, "barricada %s cheia" % bid)
	check(root.find_child("MapGeometry", false, false) != null, "cena autoral carregada")
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	check(meshes.size() > 20, "geometria autoral carregada")
	var bodies := root.find_children("*", "StaticBody3D", true, false)
	check(bodies.size() > 20, "colisão gerada")
	root.free()
	reg.free()
	if failures > 0:
		printerr("BUNKER13_FAIL %d" % failures)
		quit(1)
		return
	print("BUNKER13_OK")
	quit(0)
