class_name BarricadeSystem
extends Node

## Reparo de barricadas com hold F. A IA usa `tear_plank()` para arrancar
## tábuas; o reparo consome `repair_time` por tábua e paga `repair_points`.

var player: PlayerController
var economy: Economy
var barricades: Dictionary[String, BarricadeState] = {}
var active: BarricadeState = null

func setup(p_player: PlayerController, p_economy: Economy,
		p_barricades: Dictionary[String, BarricadeState]) -> void:
	player = p_player
	economy = p_economy
	barricades = p_barricades
	Events.player_damaged.connect(_on_player_damaged)
	Events.weapon_changed.connect(_on_weapon_changed)

func _process(delta: float) -> void:
	if player == null or not player.can_control or player.is_dead:
		cancel_repair()
		return
	var target := player.get_interactable() as BarricadeState
	if target == null or not player.is_interact_held():
		cancel_repair()
		return
	repair_tick(target, delta)

## Acumula tempo de reparo. Chamável pelo hold F e pelos testes.
func repair_tick(target: BarricadeState, delta: float) -> void:
	if target == null or target.data == null:
		return
	if target.plank_count >= target.data.max_planks:
		cancel_repair()
		return
	if active != target:
		if active != null:
			active.repair_progress = 0.0
		active = target
		target.repair_progress = 0.0

	target.repair_progress += delta
	var repair_time := maxf(target.data.repair_time, 0.01)
	while target.repair_progress >= repair_time \
		and target.plank_count < target.data.max_planks:
		target.repair_progress -= repair_time
		repair_one(target)

	var frac := clampf(target.repair_progress / repair_time, 0.0, 1.0)
	Events.barricade_progress.emit(
		target.id, frac, target.plank_count, target.data.max_planks
	)

func repair_one(target: BarricadeState) -> bool:
	if target == null or target.data == null:
		return false
	if target.plank_count >= target.data.max_planks:
		return false
	target.set_plank_count(target.plank_count + 1)
	if economy != null:
		economy.add(target.data.repair_points)
	Events.barricade_repaired.emit(target.id, target.plank_count)
	Events.barricade_changed.emit(
		target.id, target.plank_count, target.data.max_planks
	)
	return true

func tear_plank(target: BarricadeState) -> bool:
	if target == null or target.data == null:
		return false
	if target.plank_count <= 0:
		return false
	if active == target:
		target.repair_progress = 0.0
	target.set_plank_count(target.plank_count - 1)
	Events.barricade_board_broken.emit(target.id, target.plank_count)
	Events.barricade_changed.emit(
		target.id, target.plank_count, target.data.max_planks
	)
	if target.breached:
		Events.barricade_breached.emit(target.id)
	return true

func cancel_repair() -> void:
	if active == null:
		return
	active.repair_progress = 0.0
	if active.data != null:
		Events.barricade_progress.emit(
			active.id, 0.0, active.plank_count, active.data.max_planks
		)
	active = null

func _on_player_damaged(_amount: float) -> void:
	cancel_repair()

func _on_weapon_changed(_id: String, _name: String) -> void:
	cancel_repair()
