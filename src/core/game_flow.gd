class_name GameFlow
extends RefCounted

## Pedido atômico entre menu e partida. Evita flags independentes
## (`auto_start` + `selected_map`) que podiam dessincronizar.

static var _pending: Dictionary = {}


static func request(map_id: String = "", auto_start := true) -> void:
	_pending = {"map": map_id, "auto": auto_start}


static func consume() -> Dictionary:
	var out := _pending.duplicate()
	_pending.clear()
	return out


static func has_pending() -> bool:
	return not _pending.is_empty()


static func reset() -> void:
	_pending.clear()
