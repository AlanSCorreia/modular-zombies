class_name MapBuilderRegistry
extends RefCounted

## Seleciona o builder de geometria a partir do campo `builder` do mapa.
## O núcleo não conhece IDs de mapa; só o registry mantém o mapeamento.

const DEFAULT_BUILDER := "scene"
const BUILDERS := {
	"scene": preload("res://src/maps/map_scene_builder.gd"),
}

static func has(builder_id: String) -> bool:
	return BUILDERS.has(builder_id)

static func create(builder_id: String) -> RefCounted:
	if not BUILDERS.has(builder_id):
		push_error("Builder desconhecido: %s" % builder_id)
		return null
	return BUILDERS[builder_id].new()
