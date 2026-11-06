class_name Interactable
extends RefCounted

## Contrato tipado de qualquer alvo de interação do mapa.

enum Kind { DOOR, WALLBUY, PERK, BOX, BARRICADE }

var kind: Kind = Kind.DOOR
var id := ""
var name := ""
var cost := 0
var room := ""
var weapon_id := ""
var effect := ""
var node: Node3D
var body: StaticBody3D
var area: Area3D
var label: Label3D
