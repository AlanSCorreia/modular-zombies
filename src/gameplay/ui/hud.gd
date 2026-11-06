class_name SliceHUD
extends CanvasLayer

signal start_requested
signal restart_requested
signal resume_requested
signal pause_toggled

const COL_TEXT := Color(0.86, 0.84, 0.76)
const COL_DIM := Color(0.55, 0.54, 0.48)
const COL_AMBER := Color(0.95, 0.68, 0.20)

var _font_big: Font
var _font_small: Font
var _font_title: Font

var _crosshair: Control
var _hitmarker: Control
var _health_label: Label
var _health_bar: ColorRect
var _health_frac := 1.0
var _ammo_mag: Label
var _ammo_res: Label
var _weapon_label: Label
var _points: Label
var _round: Label
var _prompt: Label
var _prompt_box: PanelContainer
var _banner: Label
var _banner_sub: Label
var _banner_time := 0.0
var _hit_alpha := 0.0
var _damage: ColorRect
var _damage_alpha := 0.0
var _start: Control
var _over: Control
var _pause: Control

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font_big = load("res://assets/fonts/Oswald.ttf")
	_font_small = load("res://assets/fonts/Rajdhani-SemiBold.ttf")
	_font_title = load("res://assets/fonts/SpecialElite.ttf")
	_build()
	Events.player_health_changed.connect(_on_health)
	Events.ammo_changed.connect(_on_ammo)
	Events.points_changed.connect(_on_points)
	Events.prompt_changed.connect(_on_prompt)
	Events.hitmarker.connect(_on_hitmarker)
	Events.damage_flash.connect(_on_damage)
	Events.banner.connect(_on_banner)

func _mk(text: String, size: int, color: Color, font: Font) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _place(c: Control, anchor: Vector2, pos: Vector2, size: Vector2) -> void:
	c.anchor_left = anchor.x
	c.anchor_right = anchor.x
	c.anchor_top = anchor.y
	c.anchor_bottom = anchor.y
	c.offset_left = pos.x
	c.offset_top = pos.y
	c.offset_right = pos.x + size.x
	c.offset_bottom = pos.y + size.y

func _build() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_crosshair = Control.new()
	_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_crosshair)
	for off in [Vector2(0, -9), Vector2(0, 9), Vector2(-9, 0), Vector2(9, 0)]:
		var r := ColorRect.new()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.color = Color(0.92, 0.9, 0.84, 0.85)
		r.size = Vector2(2, 7) if off.x == 0 else Vector2(7, 2)
		r.position = off - r.size * 0.5
		_crosshair.add_child(r)

	_hitmarker = Control.new()
	_hitmarker.set_anchors_preset(Control.PRESET_CENTER)
	_hitmarker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hitmarker.modulate.a = 0.0
	root.add_child(_hitmarker)
	for p in [Vector2(-11, -11), Vector2(11, -11), Vector2(-11, 11), Vector2(11, 11)]:
		var r := ColorRect.new()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.color = Color(0.95, 0.95, 0.9)
		r.size = Vector2(9, 2)
		r.position = p
		r.pivot_offset = Vector2(4.5, 1)
		r.rotation = deg_to_rad(45) if p.x * p.y > 0 else deg_to_rad(-45)
		_hitmarker.add_child(r)

	var vc := _mk("VIDA", 15, COL_DIM, _font_small)
	_place(vc, Vector2(0, 1), Vector2(30, -66), Vector2(100, 20))
	root.add_child(vc)
	_health_label = _mk("100", 34, COL_TEXT, _font_big)
	_place(_health_label, Vector2(0, 1), Vector2(30, -48), Vector2(100, 40))
	root.add_child(_health_label)
	var bg := ColorRect.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.color = Color(0.05, 0.05, 0.05, 0.8)
	_place(bg, Vector2(0, 1), Vector2(100, -40), Vector2(180, 10))
	root.add_child(bg)
	_health_bar = ColorRect.new()
	_health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_bar.color = Color(0.62, 0.62, 0.55)
	_place(_health_bar, Vector2(0, 1), Vector2(100, -40), Vector2(180, 10))
	root.add_child(_health_bar)

	var pc := _mk("PONTOS", 15, COL_DIM, _font_small)
	pc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(pc, Vector2(0.5, 1), Vector2(-100, -64), Vector2(200, 20))
	root.add_child(pc)
	_points = _mk("500", 36, COL_AMBER, _font_big)
	_points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(_points, Vector2(0.5, 1), Vector2(-100, -50), Vector2(200, 44))
	root.add_child(_points)

	_weapon_label = _mk("GLOCK 17", 17, COL_DIM, _font_small)
	_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(_weapon_label, Vector2(1, 1), Vector2(-320, -96), Vector2(280, 22))
	root.add_child(_weapon_label)
	_ammo_mag = _mk("17", 54, COL_TEXT, _font_big)
	_ammo_mag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(_ammo_mag, Vector2(1, 1), Vector2(-250, -86), Vector2(130, 70))
	root.add_child(_ammo_mag)
	_ammo_res = _mk("/ 102", 22, COL_DIM, _font_big)
	_place(_ammo_res, Vector2(1, 1), Vector2(-112, -66), Vector2(90, 40))
	root.add_child(_ammo_res)

	_round = _mk("", 24, COL_TEXT, _font_big)
	_round.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(_round, Vector2(0.5, 0), Vector2(-180, 20), Vector2(360, 36))
	root.add_child(_round)

	_prompt_box = PanelContainer.new()
	_prompt_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(_prompt_box, Vector2(0.5, 1), Vector2(-280, -180), Vector2(560, 44))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.03, 0.03, 0.75)
	sb.border_color = Color(0.75, 0.62, 0.25, 0.7)
	sb.set_border_width_all(1)
	_prompt_box.add_theme_stylebox_override("panel", sb)
	_prompt_box.visible = false
	root.add_child(_prompt_box)
	_prompt = _mk("", 19, COL_TEXT, _font_small)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_box.add_child(_prompt)

	_banner = _mk("", 56, COL_TEXT, _font_big)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(_banner, Vector2(0.5, 0.5), Vector2(-500, -80), Vector2(1000, 80))
	_banner.modulate.a = 0.0
	root.add_child(_banner)
	_banner_sub = _mk("", 22, COL_AMBER, _font_small)
	_banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place(_banner_sub, Vector2(0.5, 0.5), Vector2(-500, -4), Vector2(1000, 34))
	_banner_sub.modulate.a = 0.0
	root.add_child(_banner_sub)

	_damage = ColorRect.new()
	_damage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_damage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage.color = Color(0.45, 0.0, 0.0, 0.0)
	root.add_child(_damage)

	_start = _overlay("BUNKER 13", "WASD mover • SHIFT correr • MOUSE atirar\nR recarregar • F interagir • ESC pausar", [
		["INICIAR", func(): start_requested.emit()],
	])
	_over = _overlay("VOCÊ MORREU", "O bunker guarda mais um corpo.", [
		["REINICIAR", func(): restart_requested.emit()],
	])
	_over.visible = false
	_pause = _overlay("PAUSADO", "ESC para continuar", [
		["CONTINUAR", func(): resume_requested.emit()],
		["REINICIAR", func(): restart_requested.emit()],
	], 0.98)
	_pause.visible = false

func _overlay(title: String, sub: String, buttons: Array, bg_alpha := 0.88) -> Control:
	var c := Control.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(c)
	var bg := ColorRect.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.color = Color(0.01, 0.012, 0.012, bg_alpha)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.add_child(center)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	vb.custom_minimum_size = Vector2(760, 0)
	center.add_child(vb)
	var t := _mk(title, 84, Color(0.82, 0.79, 0.68), _font_title)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	var s := _mk(sub, 20, COL_DIM, _font_small)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(s)
	for entry in buttons:
		var b := Button.new()
		b.text = String(entry[0])
		b.custom_minimum_size = Vector2(300, 52)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		b.add_theme_font_override("font", _font_big)
		b.add_theme_font_size_override("font_size", 26)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.06, 0.065, 0.06, 0.95)
		sb.border_color = Color(0.65, 0.25, 0.15, 0.9)
		sb.set_border_width_all(1)
		b.add_theme_stylebox_override("normal", sb)
		var cb: Callable = entry[1]
		b.pressed.connect(cb)
		vb.add_child(b)
	return c

func show_pause() -> void:
	_pause.visible = true

func hide_pause() -> void:
	_pause.visible = false

func is_pause_visible() -> bool:
	return _pause.visible


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

func set_map_name(map_name: String) -> void:
	_round.text = map_name.to_upper()

func show_start() -> void:
	if _start == null:
		return
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
	_over.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
