class_name MapContext
extends RefCounted

## Estado tipado devolvido pelo builder do mapa.

var doors: Dictionary[String, DoorState] = {}
var wallbuys: Dictionary[String, Interactable] = {}
var perks: Dictionary[String, Interactable] = {}
var box: BoxState = null
var barricades: Dictionary[String, BarricadeState] = {}
var barrels: Dictionary[String, ExplosiveBarrel] = {}
var traps: Dictionary[String, ExplosiveTrap] = {}
var radios: Dictionary[String, RadioState] = {}
var power_switches: Dictionary[String, PowerSwitchState] = {}
var power_lights: Array[OmniLight3D] = []
var spawns: Array[SpawnData] = []
var lights: Array[OmniLight3D] = []
