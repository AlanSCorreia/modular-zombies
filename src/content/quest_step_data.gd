class_name QuestStepData
extends RefCounted

var id := ""
var trigger := ""
var target := ""
var count := 1
var hint := ""
var next_steps: Array[String] = []

static func from_dict(d: Dictionary) -> QuestStepData:
	var s := QuestStepData.new()
	s.id = String(d.get("id", ""))
	s.trigger = String(d.get("trigger", "interact"))
	s.target = String(d.get("target", ""))
	s.count = int(d.get("count", 1))
	s.hint = String(d.get("hint", ""))
	for nxt in d.get("next", []):
		s.next_steps.append(String(nxt))
	return s
