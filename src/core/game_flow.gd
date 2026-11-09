class_name GameFlow
extends RefCounted

## Estado de fluxo entre o menu principal e a partida.
## `auto_start` evita pedir "INICIAR" duas vezes quando o jogador veio do menu.

static var auto_start := false


static func reset() -> void:
	auto_start = false
