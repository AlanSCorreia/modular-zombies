class_name RewardData
extends RefCounted

var type := ""
var id := ""
var amount := 0

static func from_dict(d: Dictionary) -> RewardData:
	var r := RewardData.new()
	r.type = String(d.get("type", ""))
	r.id = String(d.get("id", ""))
	r.amount = int(d.get("amount", 0))
	return r
