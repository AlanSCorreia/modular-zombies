class_name BarricadeState
extends Interactable

## Estado de runtime de uma barricada. As tábuas vêm da geometria autoral;
## o sistema só liga/desliga os meshes e controla o progresso de reparo.

var data: BarricadeData
var planks: Array[MeshInstance3D] = []
var plank_count := 0
var repair_progress := 0.0
var breached := false

func _init() -> void:
	kind = Interactable.Kind.BARRICADE

func setup_runtime() -> void:
	repair_progress = 0.0
	breached = false
	set_plank_count(data.max_planks if data != null else planks.size())

func set_plank_count(value: int) -> void:
	var limit := data.max_planks if data != null else planks.size()
	plank_count = clampi(value, 0, limit)
	breached = plank_count == 0
	if breached:
		repair_progress = 0.0
	for i in range(planks.size()):
		planks[i].visible = i < plank_count
