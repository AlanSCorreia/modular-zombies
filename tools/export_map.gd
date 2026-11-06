extends SceneTree

## Exporta a geometria estática de um mapa para GLB usando os builders legados.
## Ferramenta de migração: a fonte de verdade passa a ser o GLB/.blend.
## Uso:
##   ./run.sh --headless --script res://tools/export_map.gd -- \
##     --map map.bunker13 --out res://assets/models/maps/bunker13/bunker13.glb

const LEGACY_BUILDERS := {
	"map.slice": preload("res://src/maps/legacy/slice_builder.gd"),
	"map.bunker13": preload("res://src/maps/legacy/bunker13_builder.gd"),
}

func _arg(args: PackedStringArray, key: String, fallback: String) -> String:
	var i := args.find(key)
	if i >= 0 and i + 1 < args.size():
		return args[i + 1]
	return fallback

func _prune(node: Node) -> void:
	for child in node.get_children():
		if child is StaticBody3D or child is CollisionShape3D or child is Area3D or child is Label3D:
			child.free()
			continue
		_prune(child)

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var map_id := _arg(args, "--map", "")
	var out := _arg(args, "--out", "")
	if map_id == "" or out == "":
		push_error("uso: --map <id> --out <res://...glb>")
		quit(1)
		return

	var reg := ContentRegistry.new()
	reg.reload()
	var map: MapData = reg.get_map(map_id)
	if map == null:
		push_error("mapa não encontrado: " + map_id)
		reg.free()
		quit(1)
		return

	if not LEGACY_BUILDERS.has(map_id):
		push_error("builder legado não encontrado: " + map_id)
		reg.free()
		quit(1)
		return
	var builder = LEGACY_BUILDERS[map_id].new()

	var root := Node3D.new()
	get_root().add_child(root)
	builder.build(root, map)
	_prune(root)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out.get_base_dir()))
	var doc := GLTFDocument.new()
	doc.image_format = _arg(args, "--format", "JPEG")
	doc.lossy_quality = 0.85
	var state := GLTFState.new()
	var err := doc.append_from_scene(root, state)
	if err != OK:
		push_error("falha ao montar GLTF: %d" % err)
		root.free()
		reg.free()
		quit(1)
		return
	err = doc.write_to_filesystem(state, out)
	if err != OK:
		push_error("falha ao escrever GLB: %d" % err)
		root.free()
		reg.free()
		quit(1)
		return

	print("EXPORT_OK ", out)
	root.free()
	reg.free()
	quit(0)
