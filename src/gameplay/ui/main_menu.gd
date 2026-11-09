class_name MainMenu
extends Control

## Menu principal: jogar, opções e sair. As opções usam o mesmo GameSettings
## do pause, então a configuração é compartilhada e persistida.

const COL_TEXT := Color(0.88, 0.86, 0.78)
const COL_DIM := Color(0.66, 0.64, 0.56)
const COL_AMBER := Color(0.95, 0.68, 0.20)
const COL_BG := Color(0.025, 0.030, 0.027)

@onready var _menu_box: VBoxContainer = $Center/VBox/MenuBox
@onready var _options_box: VBoxContainer = $Center/VBox/OptionsBox
@onready var _play_button: Button = $Center/VBox/MenuBox/PlayButton
@onready var _options_button: Button = $Center/VBox/MenuBox/OptionsButton
@onready var _quit_button: Button = $Center/VBox/MenuBox/QuitButton
@onready var _back_button: Button = $Center/VBox/OptionsBox/BackButton
@onready var _volume_slider: HSlider = $Center/VBox/OptionsBox/VolumeRow/VolumeSlider
@onready var _music_slider: HSlider = $Center/VBox/OptionsBox/MusicRow/MusicSlider
@onready var _sensitivity_slider: HSlider = $Center/VBox/OptionsBox/SensitivityRow/SensitivitySlider
@onready var _quality_option: OptionButton = $Center/VBox/OptionsBox/QualityRow/QualityOption

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	GameFlow.reset()
	GameSettings.ensure_loaded()
	GameSettings.apply_audio()
	GameSettings.apply_quality(get_viewport())

	_style_button(_play_button)
	_style_button(_options_button)
	_style_button(_quit_button)
	_style_button(_back_button)

	_play_button.pressed.connect(play_game)
	_options_button.pressed.connect(show_options)
	_quit_button.pressed.connect(quit_game)
	_back_button.pressed.connect(show_menu)

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

	show_menu()
	_play_button.grab_focus()
	Sfx.play_music("music.bunker13", -14)

	# Lançamento direto (build smoke/CLI): `--map` ou `--auto-start` pula o menu.
	var args := OS.get_cmdline_user_args()
	if args.has("--map") or args.has("--auto-start"):
		call_deferred("play_game")

func show_menu() -> void:
	_menu_box.visible = true
	_options_box.visible = false
	_play_button.grab_focus()

func show_options() -> void:
	_menu_box.visible = false
	_options_box.visible = true
	_volume_slider.grab_focus()

func play_game() -> void:
	Sfx.play("ui", -6)
	Sfx.stop_music()
	GameFlow.auto_start = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func quit_game() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == KEY_ESCAPE and _options_box.visible:
		show_menu()
		get_viewport().set_input_as_handled()

func _style_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(340.0, 54.0)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", COL_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.93, 0.72))
	button.add_theme_color_override("font_pressed_color", COL_BG)
	button.add_theme_color_override("font_focus_color", COL_TEXT)
	button.add_theme_stylebox_override("normal", _box(Color(0.055, 0.062, 0.058, 0.96), COL_AMBER.darkened(0.45)))
	button.add_theme_stylebox_override("hover", _box(Color(0.10, 0.11, 0.10, 1.0), COL_AMBER))
	button.add_theme_stylebox_override("pressed", _box(COL_AMBER, COL_AMBER))
	button.add_theme_stylebox_override("focus", _box(Color(0.08, 0.09, 0.08, 1.0), COL_AMBER))

func _box(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style
