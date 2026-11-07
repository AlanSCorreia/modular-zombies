extends SceneTree

func _init() -> void:
	var reg := ContentRegistry.new()
	reg.reload()
	if reg.errors.is_empty():
		print("CONTENT_OK maps=%d weapons=%d enemies=%d melees=%d" % [
			reg.maps.size(), reg.weapons.size(), reg.enemies.size(), reg.melees.size(),
		])
		reg.free()
		quit(0)
	else:
		for e in reg.errors:
			print("CONTENT_FAIL: ", e)
		reg.free()
		quit(1)
