class_name DoorState
extends Interactable

var data: DoorData
var open := false

func _init() -> void:
	kind = Interactable.Kind.DOOR
