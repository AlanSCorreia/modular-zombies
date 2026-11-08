class_name GameSettings
extends RefCounted

## Settings persistentes (sensibilidade, volumes e qualidade).

const PATH := "user://settings.cfg"
const VERSION := 1
const DEFAULT_SENSITIVITY := 1.0
const DEFAULT_MASTER := 0.8
const DEFAULT_MUSIC := 0.8
const DEFAULT_QUALITY := 1

static var mouse_sensitivity := DEFAULT_SENSITIVITY
static var master_volume := DEFAULT_MASTER
static var music_volume := DEFAULT_MUSIC
static var quality := DEFAULT_QUALITY
static var _loaded := false

static func ensure_loaded() -> void:
	if not _loaded:
		load_settings()

static func load_settings() -> void:
	_loaded = true
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		_apply_defaults()
		return
	mouse_sensitivity = clampf(float(cfg.get_value("input", "sensitivity", DEFAULT_SENSITIVITY)), 0.2, 2.0)
	master_volume = clampf(float(cfg.get_value("audio", "master", DEFAULT_MASTER)), 0.0, 1.0)
	music_volume = clampf(float(cfg.get_value("audio", "music", DEFAULT_MUSIC)), 0.0, 1.0)
	quality = clampi(int(cfg.get_value("video", "quality", DEFAULT_QUALITY)), 0, 2)

static func save_settings() -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", VERSION)
	cfg.set_value("input", "sensitivity", mouse_sensitivity)
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("video", "quality", quality)
	return cfg.save(PATH) == OK

static func reset(save := true) -> void:
	_apply_defaults()
	_loaded = true
	if save:
		save_settings()

static func set_sensitivity(value: float, save := true) -> void:
	mouse_sensitivity = clampf(value, 0.2, 2.0)
	if save:
		save_settings()

static func set_master_volume(value: float, save := true) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	if save:
		save_settings()

static func set_music_volume(value: float, save := true) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	if save:
		save_settings()

static func set_quality(value: int, save := true) -> void:
	quality = clampi(value, 0, 2)
	if save:
		save_settings()

static func apply_audio() -> void:
	if Sfx == null:
		return
	Sfx.set_master_volume(master_volume, false)
	Sfx.set_music_volume(music_volume)

static func apply_quality(viewport: Viewport) -> void:
	if viewport == null:
		return
	match quality:
		0:
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
			viewport.scaling_3d_scale = 0.5
		2:
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			viewport.scaling_3d_scale = 1.0
		_:
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			viewport.scaling_3d_scale = 0.75

static func _apply_defaults() -> void:
	mouse_sensitivity = DEFAULT_SENSITIVITY
	master_volume = DEFAULT_MASTER
	music_volume = DEFAULT_MUSIC
	quality = DEFAULT_QUALITY
