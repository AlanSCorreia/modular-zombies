extends SceneTree

func _init() -> void:
	var reg := ContentRegistry.new()
	reg.reload()
	var ok := true
	var valid := QuestValidator.validate(reg.quests, reg.maps, reg.weapons)
	ok = ok and valid.is_empty()

	var cycle := _quest("quest.cycle", [
		_step("a", "b"),
		_step("b", "a"),
	])
	var cycle_errs := QuestValidator.validate({"quest.cycle": cycle}, reg.maps, reg.weapons)
	ok = ok and _has(cycle_errs, "ciclo")

	var orphan := _quest("quest.orphan", [
		_step("a", "c"),
		_step("b", ""),
		_step("c", ""),
	])
	var orphan_errs := QuestValidator.validate({"quest.orphan": orphan}, reg.maps, reg.weapons)
	ok = ok and _has(orphan_errs, "órfão")

	var missing := _quest("quest.missing", [
		_step("a", "ghost"),
	])
	var missing_errs := QuestValidator.validate({"quest.missing": missing}, reg.maps, reg.weapons)
	ok = ok and _has(missing_errs, "next inexistente")

	var bad_reward := _quest("quest.reward", [_step("a", "")])
	var reward := RewardData.from_dict({"type": "weapon", "id": "weapon.ghost"})
	bad_reward.rewards.append(reward)
	var reward_errs := QuestValidator.validate({"quest.reward": bad_reward}, reg.maps, reg.weapons)
	ok = ok and _has(reward_errs, "arma de reward inexistente")

	reg.free()
	if ok:
		print("QUEST_VALIDATOR_OK valid=%d" % valid.size())
		quit(0)
	else:
		print("VALID_ERRORS ", valid)
		print("CYCLE_ERRORS ", cycle_errs)
		print("ORPHAN_ERRORS ", orphan_errs)
		print("MISSING_ERRORS ", missing_errs)
		print("REWARD_ERRORS ", reward_errs)
		printerr("QUEST_VALIDATOR_FAIL")
		quit(1)

func _step(id: String, next_id: String) -> QuestStepData:
	var s := QuestStepData.new()
	s.id = id
	s.trigger = "interact"
	s.target = "radio_1"
	s.count = 1
	if next_id != "":
		s.next_steps.append(next_id)
	return s

func _quest(id: String, steps: Array) -> QuestData:
	var q := QuestData.new()
	q.id = id
	q.name = id
	for step in steps:
		q.steps.append(step)
	return q

func _has(errors: Array[String], needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false
