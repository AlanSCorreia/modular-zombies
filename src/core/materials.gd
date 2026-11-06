class_name MatLib
extends RefCounted

## Biblioteca de materiais PBR com cache.

static var _cache: Dictionary = {}

static func textured(folder: String, scale: float = 0.5, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var key := "tex|%s|%.3f|%s" % [folder, scale, str(tint)]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	var base := "res://assets/textures/%s/" % folder
	var diff = load(base + "diff.jpg")
	if diff != null:
		m.albedo_texture = diff
		m.albedo_color = tint
	var nor = load(base + "nor.jpg")
	if nor != null:
		m.normal_enabled = true
		m.normal_texture = nor
		m.normal_scale = 1.0
	var rough = load(base + "rough.jpg")
	if rough != null:
		m.roughness_texture = rough
		m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
		m.roughness = 1.0
	var ao = load(base + "ao.jpg")
	if ao != null:
		m.ao_enabled = true
		m.ao_texture = ao
		m.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GRAYSCALE
		m.ao_light_affect = 0.5
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(scale, scale, scale)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_cache[key] = m
	return m

static func simple(color: Color, metallic: float = 0.0, roughness: float = 0.8) -> StandardMaterial3D:
	var key := "simple|%s|%.2f|%.2f" % [str(color), metallic, roughness]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = roughness
	_cache[key] = m
	return m

static func emissive(color: Color, energy: float = 4.0) -> StandardMaterial3D:
	var key := "emis|%s|%.2f" % [str(color), energy]
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_cache[key] = m
	return m

static func gun_metal() -> StandardMaterial3D:
	return simple(Color(0.19, 0.195, 0.205), 0.8, 0.36)

static func gun_worn() -> StandardMaterial3D:
	return simple(Color(0.24, 0.225, 0.21), 0.8, 0.5)

static func gun_polymer() -> StandardMaterial3D:
	return simple(Color(0.075, 0.078, 0.08), 0.2, 0.68)

static func gun_wood() -> StandardMaterial3D:
	return simple(Color(0.30, 0.16, 0.075), 0.05, 0.5)

static func glove() -> StandardMaterial3D:
	return simple(Color(0.035, 0.038, 0.034), 0.05, 0.85)

static func blood() -> StandardMaterial3D:
	var key := "blood"
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.20, 0.008, 0.006)
	m.roughness = 0.35
	m.metallic = 0.0
	_cache[key] = m
	return m

static func window_glass() -> StandardMaterial3D:
	var key := "glass"
	if _cache.has(key):
		return _cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.02, 0.035, 0.05, 1.0)
	m.metallic = 0.4
	m.roughness = 0.15
	m.emission_enabled = true
	m.emission = Color(0.015, 0.03, 0.06)
	m.emission_energy_multiplier = 1.2
	_cache[key] = m
	return m

static func decal_texture() -> ImageTexture:
	var key := "decal_tex"
	if _cache.has(key):
		return _cache[key]
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var dx := (x - 15.5) / 15.5
			var dy := (y - 15.5) / 15.5
			var d := sqrt(dx * dx + dy * dy)
			var a := clampf(1.0 - d, 0.0, 1.0)
			a = a * a * 0.95
			img.set_pixel(x, y, Color(0.02, 0.018, 0.016, a))
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

static func blood_texture() -> ImageTexture:
	var key := "blood_tex"
	if _cache.has(key):
		return _cache[key]
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = 991
	for i in range(46):
		var x := rng.randi_range(18, 46)
		var y := rng.randi_range(18, 46)
		var r := rng.randi_range(2, 8)
		for yy in range(maxi(0, y - r), mini(64, y + r)):
			for xx in range(maxi(0, x - r), mini(64, x + r)):
				var d := Vector2(xx - x, yy - y).length() / float(r)
				if d < 1.0:
					var a := (1.0 - d) * rng.randf_range(0.7, 1.0)
					img.set_pixel(xx, yy, Color(0.22, 0.01, 0.008, a))
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

static func smoke_texture() -> ImageTexture:
	var key := "smoke_tex"
	if _cache.has(key):
		return _cache[key]
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var dx := (x - 15.5) / 15.5
			var dy := (y - 15.5) / 15.5
			var d := sqrt(dx * dx + dy * dy)
			var a := clampf(1.0 - d, 0.0, 1.0)
			a = pow(a, 2.2) * 0.55
			img.set_pixel(x, y, Color(0.7, 0.68, 0.62, a))
	var tex := ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex
