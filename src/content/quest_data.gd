class_name QuestData
extends RefCounted

var id := ""
var name := ""
var type := "music"
var requires_coop := false
var repeatable := false
var steps: Array[QuestStepData] = []
var rewards: Array[RewardData] = []

static func from_dict(d: Dictionary) -> QuestData:
	var q := QuestData.new()
	q.id = String(d.get("id", ""))
	q.name = String(d.get("name", ""))
	q.type = String(d.get("type", "music"))
	q.requires_coop = bool(d.get("requires_coop", false))
	q.repeatable = bool(d.get("repeatable", false))
	for step in d.get("steps", []):
		q.steps.append(QuestStepData.from_dict(step))
	for reward in d.get("rewards", []):
		q.rewards.append(RewardData.from_dict(reward))
	return q
