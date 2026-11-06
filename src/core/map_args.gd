class_name MapArgs
extends RefCounted

## Parsing de argumentos de mapa, isolado do GameRoot para ser testável
## sem depender dos autoloads da cena principal.

const DEFAULT_MAP := "map.slice"

static func map_id_from_args(args: PackedStringArray) -> String:
	var i := args.find("--map")
	if i >= 0 and i + 1 < args.size():
		return args[i + 1]
	return DEFAULT_MAP
