class_name MapBuilderRegistry
extends RefCounted

## Seleciona o builder de geometria a partir do campo `builder` do mapa.
## O núcleo não conhece IDs de mapa; só o registry mantém o mapeamento.

const DEFAULT_BUILDER := "slice"
const BUILDERS := {
	"slice": preload("res://src/maps/slice/slice_builder.gd"),
	"bunker13": preload("res://src/maps/bunker13/builder.gd"),
}

static func has(builder_id: String) -> bool:
	return BUILDERS.has(builder_id)

static func create(builder_id: String) -> RefCounted:
	if not BUILDERS.has(builder_id):
		push_error("Builder desconhecido: %s" % builder_id)
		return null
	return BUILDERS[builder_id].new()
