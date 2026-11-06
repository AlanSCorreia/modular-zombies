class_name BarricadeState
extends Interactable

var data: BarricadeData
var planks: Array[MeshInstance3D] = []

func _init() -> void:
	kind = Interactable.Kind.BARRICADE
