@tool
extends EditorPlugin

var dock: Control
var map_list: OptionButton
var output: TextEdit

func _enter_tree() -> void:
	dock = VBoxContainer.new()
	dock.name = "BunkerTools"
	dock.custom_minimum_size = Vector2(0, 160)

	var title := Label.new()
	title.text = "Bunker Tools — Mapas JSON"
	dock.add_child(title)

	map_list = OptionButton.new()
	map_list.item_selected.connect(func(_i): _validate())
	dock.add_child(map_list)

	var row := HBoxContainer.new()
	dock.add_child(row)

	var validate_btn := Button.new()
	validate_btn.text = "Validar"
	validate_btn.pressed.connect(_validate)
	row.add_child(validate_btn)

	var play_btn := Button.new()
	play_btn.text = "Playtest"
	play_btn.pressed.connect(func(): EditorInterface.play_main_scene())
	row.add_child(play_btn)

	var reload_btn := Button.new()
	reload_btn.text = "Recarregar JSON"
	reload_btn.pressed.connect(_refresh)
	row.add_child(reload_btn)

	output = TextEdit.new()
	output.editable = false
	output.custom_minimum_size = Vector2(0, 90)
	dock.add_child(output)

	add_control_to_bottom_panel(dock, "Bunker Tools")
	_refresh()

func _exit_tree() -> void:
	if dock != null:
		remove_control_from_bottom_panel(dock)
		dock.queue_free()

func _refresh() -> void:
	map_list.clear()
	var da := DirAccess.open("res://content/maps")
	if da == null:
		output.text = "content/maps não encontrado."
		return
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		if f.ends_with(".json"):
			map_list.add_item(f)
		f = da.get_next()
	da.list_dir_end()
	_validate()

func _validate() -> void:
	var reg := ContentRegistry.new()
	reg.reload()
	var lines: Array[String] = []
	lines.append("maps=%d weapons=%d enemies=%d" % [reg.maps.size(), reg.weapons.size(), reg.enemies.size()])
	if reg.errors.is_empty():
		lines.append("OK — conteúdo válido")
	else:
		for e in reg.errors:
			lines.append("ERRO: " + e)
	output.text = "\n".join(lines)
	reg.free()
