class_name BoxState
extends Interactable

var data: BoxData
var lid: Node3D

func _init() -> void:
	kind = Interactable.Kind.BOX
