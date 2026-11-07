class_name Economy
extends RefCounted

## Pontos e compras. Emite o sinal global para o HUD continuar desacoplado.

var points := 0

func setup(starting_points: int) -> void:
	points = starting_points
	Events.points_changed.emit(points)

func add(amount: int) -> void:
	points += amount
	Events.points_changed.emit(points)

func can_afford(cost: int) -> bool:
	return points >= cost

func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	points -= cost
	Events.points_changed.emit(points)
	return true

func set_points(value: int) -> void:
	points = value
	Events.points_changed.emit(points)
