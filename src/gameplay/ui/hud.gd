class_name SliceHUD
extends CanvasLayer

signal start_requested
signal restart_requested
signal resume_requested
signal pause_toggled
signal menu_requested

const COL_TEXT := Color(0.86, 0.84, 0.76)
const COL_DIM := Color(0.66, 0.64, 0.56)
const COL_AMBER := Color(0.95, 0.68, 0.20)

@onready var _crosshair: Control = $Root/Crosshair
@onready var _hitmarker: Control = $Root/Hitmarker
@onready var _health_label: Label = $Root/HealthLabel
@onready var _health_bar: ColorRect = $Root/HealthBar
@onready var _ammo_mag: Label = $Root/AmmoMag
@onready var _ammo_res: Label = $Root/AmmoRes
@onready var _weapon_label: Label = $Root/WeaponLabel
@onready var _slot_label: Label = $Root/SlotLabel
@onready var _grenade_label: Label = $Root/GrenadeLabel
@onready var _points: Label = $Root/Points
@onready var _round: Label = $Root/RoundLabel
@onready var _prompt: Label = $Root/PromptBox/Prompt
@onready var _prompt_box: PanelContainer = $Root/PromptBox
@onready var _repair_box: PanelContainer = $Root/RepairBox
@onready var _repair_label: Label = $Root/RepairBox/VBox/RepairLabel
@onready var _repair_bar: ColorRect = $Root/RepairBox/VBox/RepairBar
@onready var _repair_fill: ColorRect = $Root/RepairBox/VBox/RepairBar/Fill
@onready var _banner: Label = $Root/Banner
@onready var _banner_sub: Label = $Root/BannerSub
@onready var _damage: ColorRect = $Root/Damage
@onready var _start: Control = $Start
@onready var _over: Control = $Over
@onready var _pause: Control = $Pause
@onready var _start_button: Button = $Start/Center/VBox/StartButton
@onready var _over_restart: Button = $Over/Center/VBox/RestartButton
@onready var _over_menu: Button = $Over/Center/VBox/MenuButton
@onready var _pause_continue: Button = $Pause/Center/VBox/ContinueButton
@onready var _pause_restart: Button = $Pause/Center/VBox/RestartButton
@onready var _pause_menu: Button = $Pause/Center/VBox/MenuButton
@onready var _volume_slider: HSlider = $Pause/Center/VBox/VolumeRow/VolumeSlider
@onready var _music_slider: HSlider = $Pause/Center/VBox/MusicRow/MusicSlider
@onready var _sensitivity_slider: HSlider = $Pause/Center/VBox/SensitivityRow/SensitivitySlider
@onready var _quality_option: OptionButton = $Pause/Center/VBox/QualityRow/QualityOption

var _health_frac := 1.0
var _banner_time := 0.0
var _hit_alpha := 0.0
var _damage_alpha := 0.0
var _map_name := ""

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_start_button.pressed.connect(func(): start_requested.emit())
	_over_restart.pressed.connect(func(): restart_requested.emit())
	_over_menu.pressed.connect(func(): menu_requested.emit())
	_pause_continue.pressed.connect(func(): resume_requested.emit())
	_pause_restart.pressed.connect(func(): restart_requested.emit())
	_pause_menu.pressed.connect(func(): menu_requested.emit())
	GameSettings.ensure_loaded()
	_volume_slider.value = GameSettings.master_volume
	_volume_slider.value_changed.connect(func(value: float):
		GameSettings.set_master_volume(value)
		GameSettings.apply_audio()
	)
	_music_slider.value = GameSettings.music_volume
	_music_slider.value_changed.connect(func(value: float):
		GameSettings.set_music_volume(value)
		GameSettings.apply_audio()
	)
	_sensitivity_slider.value = GameSettings.mouse_sensitivity
	_sensitivity_slider.value_changed.connect(func(value: float):
		GameSettings.set_sensitivity(value)
	)
	_quality_option.selected = GameSettings.quality
	_quality_option.item_selected.connect(func(index: int):
		GameSettings.set_quality(index)
		GameSettings.apply_quality(get_viewport())
	)
	_start.visible = true
	_over.visible = false
	_pause.visible = false
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hitmarker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Events.player_health_changed.connect(_on_health)
	Events.ammo_changed.connect(_on_ammo)
	Events.slot_changed.connect(_on_slot)
	Events.grenades_changed.connect(_on_grenades)
	Events.points_changed.connect(_on_points)
	Events.prompt_changed.connect(_on_prompt)
	Events.hitmarker.connect(_on_hitmarker)
	Events.damage_flash.connect(_on_damage)
	Events.banner.connect(_on_banner)
	Events.barricade_progress.connect(_on_barricade_progress)

func show_pause() -> void:
	_pause.visible = true

func hide_pause() -> void:
	_pause.visible = false

func is_pause_visible() -> bool:
	return _pause.visible

func is_start_visible() -> bool:
	return _start.visible

func volume_slider_value() -> float:
	return _volume_slider.value

func music_slider_value() -> float:
	return _music_slider.value

func sensitivity_slider_value() -> float:
	return _sensitivity_slider.value

func quality_option_value() -> int:
	return _quality_option.selected

func mouse_filters_ok() -> bool:
	return _crosshair.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and _hitmarker.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and _damage.mouse_filter == Control.MOUSE_FILTER_IGNORE \
		and _prompt_box.mouse_filter == Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		pause_toggled.emit()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	_hit_alpha = maxf(0.0, _hit_alpha - delta * 5.0)
	_hitmarker.modulate.a = _hit_alpha
	_damage_alpha = maxf(0.0, _damage_alpha - delta * 2.0)
	_damage.color.a = _damage_alpha * 0.35
	if _banner_time > 0.0:
		_banner_time -= delta
		var a := clampf(_banner_time, 0.0, 0.4)
		_banner.modulate.a = a
		_banner_sub.modulate.a = a

func _on_health(hp: float, max_hp: float) -> void:
	_health_frac = clampf(hp / max_hp, 0.0, 1.0)
	_health_label.text = str(int(ceil(maxf(hp, 0.0))))
	_health_bar.size.x = 180.0 * _health_frac
	_health_bar.color = Color(0.72, 0.12, 0.08) if _health_frac < 0.35 else Color(0.62, 0.62, 0.55)

func _on_ammo(mag: int, reserve: int, weapon_name: String) -> void:
	_ammo_mag.text = str(mag)
	_ammo_res.text = "/ %d" % reserve
	_weapon_label.text = weapon_name

func _on_slot(index: int, count: int) -> void:
	_slot_label.text = "SLOT %d/%d" % [index, count]

func _on_grenades(count: int) -> void:
	_grenade_label.text = "GRANADAS %d" % count

func grenade_label_text() -> String:
	return _grenade_label.text

func _on_points(points: int) -> void:
	_points.text = str(points)

func _on_prompt(text: String, show: bool) -> void:
	_prompt.text = text
	_prompt_box.visible = show

func _on_hitmarker() -> void:
	_hit_alpha = 1.0

func _on_damage() -> void:
	_damage_alpha = 1.0

func _on_banner(title: String, sub: String, duration: float) -> void:
	_banner.text = title
	_banner_sub.text = sub
	_banner_time = duration
	_banner.modulate.a = 1.0
	_banner_sub.modulate.a = 1.0

func _on_barricade_progress(_id: String, progress: float, planks: int,
		max_planks: int) -> void:
	if progress <= 0.0 or planks >= max_planks:
		_repair_box.visible = false
		return
	_repair_box.visible = true
	_repair_label.text = "REPARANDO — %d/%d" % [planks, max_planks]
	var width := maxf(_repair_bar.size.x, 1.0)
	_repair_fill.size.x = width * clampf(progress, 0.0, 1.0)

func set_map_name(map_name: String) -> void:
	_map_name = map_name
	_round.text = map_name.to_upper()

func set_round(round_no: int) -> void:
	if _map_name == "":
		_round.text = "RODADA %d" % round_no
	else:
		_round.text = "%s — RODADA %d" % [_map_name.to_upper(), round_no]

func round_label_text() -> String:
	return _round.text

func is_gameover_visible() -> bool:
	return _over.visible

func show_start() -> void:
	if _start == null:
		return
	_repair_box.visible = false
	_start.visible = true
	_over.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_start() -> void:
	if _start == null:
		return
	_start.visible = false
	_start.queue_free()
	_start = null

func show_gameover() -> void:
	_repair_box.visible = false
	_over.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
