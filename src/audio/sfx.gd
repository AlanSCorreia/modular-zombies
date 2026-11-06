extends Node

## Gerenciador de áudio: efeitos 2D/3D, música ambiente e stingers originais.

const POOL_2D := 12
const POOL_3D := 16

var _streams: Dictionary = {}
var _music: AudioStreamPlayer
var _heart: AudioStreamPlayer
var _pool_2d: Array[AudioStreamPlayer] = []
var _pool_3d: Array[AudioStreamPlayer3D] = []
var _pool_2d_idx := 0
var _pool_3d_idx := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var master := AudioServer.get_bus_index("Master")
	var rev := AudioEffectReverb.new()
	rev.room_size = 0.62
	rev.damping = 0.55
	rev.wet = 0.10
	rev.dry = 0.95
	AudioServer.add_bus_effect(master, rev)

	_streams["gun_pistol"] = [load("res://assets/audio/guns/cz.wav")]
	_streams["gun_smg"] = [load("res://assets/audio/guns/cz.wav")]
	_streams["gun_shotgun"] = [load("res://assets/audio/guns/shotty.wav")]
	_streams["gun_rifle"] = [load("res://assets/audio/guns/mosin.wav")]
	_streams["gun_raygun"] = [load("res://assets/audio/guns/raygun_synth.ogg")]

	_streams["reload"] = [
		load("res://assets/audio/foley/impactMetal_light_000.ogg"),
		load("res://assets/audio/foley/impactMetal_light_001.ogg"),
		load("res://assets/audio/foley/impactMetal_light_002.ogg"),
	]
	_streams["hit_flesh"] = [
		load("res://assets/audio/foley/impactSoft_heavy_000.ogg"),
		load("res://assets/audio/foley/impactSoft_heavy_001.ogg"),
		load("res://assets/audio/foley/impactSoft_heavy_002.ogg"),
	]
	_streams["hit_wall"] = [
		load("res://assets/audio/foley/impactPlank_medium_000.ogg"),
		load("res://assets/audio/foley/impactPlank_medium_001.ogg"),
	]
	_streams["shell"] = _streams["reload"]
	_streams["footstep"] = [
		load("res://assets/audio/foley/footstep_concrete_000.ogg"),
		load("res://assets/audio/foley/footstep_concrete_001.ogg"),
		load("res://assets/audio/foley/footstep_concrete_002.ogg"),
		load("res://assets/audio/foley/footstep_concrete_003.ogg"),
		load("res://assets/audio/foley/footstep_concrete_004.ogg"),
	]
	_streams["ui"] = _streams["reload"]
	_streams["powerup"] = [load("res://assets/audio/ui/powerup.ogg")]
	_streams["box_hum"] = [load("res://assets/audio/ui/box_hum.ogg")]
	_streams["round_end"] = [load("res://assets/audio/music/round_end.ogg")]
	_streams["round_start"] = [load("res://assets/audio/music/round_start.ogg")]
	_streams["heartbeat"] = [load("res://assets/audio/ui/heartbeat.ogg")]

	var zg: Array = []
	for i in range(1, 25):
		var p := "res://assets/audio/zombies/zombie-%d.wav" % i
		var s = load(p)
		if s != null:
			zg.append(s)
	_streams["zombie_growl"] = zg
	_streams["zombie_attack"] = zg
	_streams["zombie_death"] = zg

	for i in range(POOL_2D):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool_2d.append(p)
	for i in range(POOL_3D):
		var p := AudioStreamPlayer3D.new()
		p.unit_size = 8.0
		p.max_distance = 45.0
		p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		add_child(p)
		_pool_3d.append(p)

	_music = AudioStreamPlayer.new()
	_music.name = "AmbientMusic"
	var amb: AudioStreamOggVorbis = load("res://assets/audio/music/ambient_drone.ogg")
	amb.loop = true
	_music.stream = amb
	_music.volume_db = -20.0
	add_child(_music)
	_music.play()

	_heart = AudioStreamPlayer.new()
	_heart.stream = _streams["heartbeat"][0]
	_heart.volume_db = -8.0
	add_child(_heart)

func set_music_volume(db: float) -> void:
	_music.volume_db = db

func _acquire_2d() -> AudioStreamPlayer:
	for i in range(_pool_2d.size()):
		var idx := (_pool_2d_idx + i) % _pool_2d.size()
		var p := _pool_2d[idx]
		if not p.playing:
			_pool_2d_idx = (idx + 1) % _pool_2d.size()
			return p
	var p := _pool_2d[_pool_2d_idx]
	_pool_2d_idx = (_pool_2d_idx + 1) % _pool_2d.size()
	p.stop()
	return p

func _acquire_3d() -> AudioStreamPlayer3D:
	for i in range(_pool_3d.size()):
		var idx := (_pool_3d_idx + i) % _pool_3d.size()
		var p := _pool_3d[idx]
		if not p.playing:
			_pool_3d_idx = (idx + 1) % _pool_3d.size()
			return p
	var p := _pool_3d[_pool_3d_idx]
	_pool_3d_idx = (_pool_3d_idx + 1) % _pool_3d.size()
	p.stop()
	return p

func play(key: String, volume_db: float = 0.0, pitch: float = 1.0, pitch_var: float = 0.0) -> void:
	if not _streams.has(key):
		return
	var arr: Array = _streams[key]
	if arr.is_empty():
		return
	var p := _acquire_2d()
	p.stream = arr[randi() % arr.size()]
	p.volume_db = volume_db
	p.pitch_scale = maxf(0.05, pitch + randf_range(-pitch_var, pitch_var))
	p.play()

func play_3d(key: String, world_pos: Vector3, volume_db: float = 0.0, pitch: float = 1.0, pitch_var: float = 0.05) -> void:
	if not _streams.has(key):
		return
	var arr: Array = _streams[key]
	if arr.is_empty():
		return
	var p := _acquire_3d()
	p.stream = arr[randi() % arr.size()]
	p.volume_db = volume_db
	p.pitch_scale = maxf(0.05, pitch + randf_range(-pitch_var, pitch_var))
	p.global_position = world_pos
	p.play()

func get_random(key: String):
	if not _streams.has(key):
		return null
	var arr: Array = _streams[key]
	if arr.is_empty():
		return null
	return arr[randi() % arr.size()]

func play_music(key: String, volume_db: float = -6.0) -> void:
	if not _streams.has(key):
		return
	var p := AudioStreamPlayer.new()
	p.stream = _streams[key][0]
	p.volume_db = volume_db
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

func heartbeat() -> void:
	_heart.play()

func _exit_tree() -> void:
	if _music != null:
		_music.stop()
	if _heart != null:
		_heart.stop()
	for p in _pool_2d:
		p.stop()
	for p in _pool_3d:
		p.stop()
