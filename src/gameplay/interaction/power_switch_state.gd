class_name PowerSwitchState
extends Interactable

var data: PowerSwitchData
var used := false

func _init() -> void:
	kind = Interactable.Kind.POWER
