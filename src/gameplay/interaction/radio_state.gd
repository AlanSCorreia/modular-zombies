class_name RadioState
extends Interactable

var data: RadioData
var used := false

func _init() -> void:
	kind = Interactable.Kind.RADIO
