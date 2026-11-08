@tool
extends EditorPlugin

var dock: Control
var map_list: OptionButton
var new_id: LineEdit
var new_name: LineEdit
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

	var form := HBoxContainer.new()
	dock.add_child(form)
	new_id = LineEdit.new()
	new_id.placeholder_text = "map.novo_mapa"
	new_id.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form.add_child(new_id)
	new_name = LineEdit.new()
	new_name.placeholder_text = "NOME DO MAPA"
	new_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form.add_child(new_name)

	var row := HBoxContainer.new()
	dock.add_child(row)

	var create_btn := Button.new()
	create_btn.text = "Novo (template)"
	create_btn.pressed.connect(_create)
	row.add_child(create_btn)

	var dup_btn := Button.new()
	dup_btn.text = "Duplicar selecionado"
	dup_btn.pressed.connect(_duplicate)
	row.add_child(dup_btn)

	var validate_btn := Button.new()
	validate_btn.text = "Validar"
	validate_btn.pressed.connect(_validate)
	row.add_child(validate_btn)

	var play_btn := Button.new()
	play_btn.text = "Playtest mapa"
	play_btn.pressed.connect(_playtest)
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

func _selected_map_id() -> String:
	if map_list == null or map_list.selected < 0:
		return ""
	return "map." + map_list.get_item_text(map_list.selected).get_basename()

func _create() -> void:
	var result := MapTools.create_from_template(new_id.text, new_name.text)
	_show_result(result)
	_refresh()

func _duplicate() -> void:
	var source := _selected_map_id()
	if source == "":
		output.text = "Selecione um mapa para duplicar."
		return
	var result := MapTools.duplicate_map(source, new_id.text, new_name.text)
	_show_result(result)
	_refresh()

func _show_result(result: Dictionary) -> void:
	if result.get("ok", false):
		output.text = "OK: " + String(result.get("path", ""))
	else:
		output.text = "ERRO: " + String(result.get("error", "falha"))

func _playtest() -> void:
	var map_id := _selected_map_id()
	if map_id == "":
		output.text = "Selecione um mapa para o playtest."
		return
	if not MapArgs.set_playtest_override(map_id):
		output.text = "ERRO: falha ao gravar override de playtest."
		return
	output.text = "Playtest: " + map_id
	EditorInterface.play_main_scene()

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
