class_name MapContext
extends RefCounted

## Estado tipado devolvido pelo builder do mapa.

var doors: Dictionary[String, DoorState] = {}
var wallbuys: Dictionary[String, Interactable] = {}
var perks: Dictionary[String, Interactable] = {}
var box: BoxState = null
var barricades: Dictionary[String, BarricadeState] = {}
var spawns: Array[SpawnData] = []
var lights: Array[OmniLight3D] = []
