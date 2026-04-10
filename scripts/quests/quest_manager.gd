extends Node

signal quest_added(quest_data)
signal quest_updated(quest_data)
signal quest_completed(quest_data)

var current_quests := {}
var completed_quests := {}
var quest_data := {}

func _ready():
	_load_quest_json()
	rebuild_from_gamestate()


func _load_quest_json():
	var file = FileAccess.open("res://scripts/quests/quests.json", FileAccess.READ)
	if file == null:
		push_error("Quest JSON not found!")
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("quests"):
		push_error("Invalid quest JSON format")
		return

	quest_data = parsed["quests"]


func rebuild_from_gamestate():
	current_quests.clear()
	completed_quests.clear()

	for id in GameState.quest_state.keys():
		if not quest_data.has(id):
			continue

		var state = GameState.quest_state[id]
		if typeof(state) != TYPE_DICTIONARY:
			continue

		var quest = _build_quest(id)

		match state.get("status", ""):
			"started":
				current_quests[id] = quest
			"completed":
				completed_quests[id] = quest


func add_quest(id: String):
	if GameState.quest_state.has(id):
		return
	if not quest_data.has(id):
		push_warning("QuestManager.add_quest: unknown quest id: " + id)
		return

	GameState.quest_state[id] = {
		"status": "started",
		"is_new": true,
		"notified_items": []
	}

	var quest = _build_quest(id)
	current_quests[id] = quest
	quest_added.emit(quest)
	SaveSystem.save_game()


func complete_quest(id: String):
	if not current_quests.has(id):
		return

	GameState.quest_state[id]["status"] = "completed"
	GameState.quest_state[id]["is_new"] = false

	var quest = current_quests[id]
	current_quests.erase(id)
	completed_quests[id] = quest

	quest_completed.emit(quest)
	SaveSystem.save_game()


func on_item_picked(item_id: String) -> void:
	var picked := _norm(item_id)
	print("[QuestManager] on_item_picked:", picked, " active:", current_quests.keys())

	for qid in current_quests.keys():
		var state: Dictionary = GameState.quest_state.get(qid, {})
		if state.get("status", "") != "started":
			continue

		var quest := _build_quest(qid)
		var needed_raw: Array = quest.get("needs_items", [])
		if needed_raw.is_empty():
			continue

		var needed_norm: Array = []
		for x in needed_raw:
			needed_norm.append(_norm(str(x)))

		print("[QuestManager] check", qid, "needs:", needed_norm)

		if not needed_norm.has(picked):
			continue

		_update_quest_progress(qid, picked)
		return # falls 1 item nur für 1 quest zählen soll


func _update_quest_progress(id: String, picked_norm: String) -> void:
	if not current_quests.has(id):
		return

	var state: Dictionary = GameState.quest_state.get(id, {})
	state["is_new"] = true

	state["notified_items"] = state.get("notified_items", [])
	if state["notified_items"].has(picked_norm):
		print("[QuestManager] already notified:", picked_norm, "for", id)
		return

	state["notified_items"].append(picked_norm)
	GameState.quest_state[id] = state

	var quest := _build_quest(id)

	print("[QuestManager] UPDATE QUEST:", id, "popup now")

	PopupManager.popup_update_quest(quest)
	quest_updated.emit(quest)

	#if _are_all_items_collected(quest):
		#complete_quest(id)

	SaveSystem.save_game()


func _build_quest(id: String) -> Dictionary:
	var q: Dictionary = quest_data[id]
	var state: Dictionary = GameState.quest_state.get(id, {})
	var lang = TranslationServer.get_locale().substr(0, 2)

	var title_dict: Dictionary = q.get("title", {})
	var desc_dict: Dictionary = q.get("description", {})

	var title_key := "text_%s" % lang
	var desc_key := "text_%s" % lang

	return {
		"id": id,
		"title": title_dict.get(title_key, title_dict.get("text_en", "")),
		"description": desc_dict.get(desc_key, desc_dict.get("text_en", "")),
		"is_new": state.get("is_new", false),
		"needs_items": q.get("needs_items", []),
		"spacegram_hint": q.get("spacegram_hint", false)
	}



func _are_all_items_collected(quest: Dictionary) -> bool:
	for item_id in quest.get("needs_items", []):
		if not GameState.picked_items.has(item_id):
			return false
	return true


func _norm(s: String) -> String:
	return s.strip_edges().to_lower()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_on_language_changed()

func _on_language_changed() -> void:
	# alle Quest-Dicts neu in aktueller Sprache bauen
	for qid in current_quests.keys():
		var q := _build_quest(qid)
		current_quests[qid] = q
		quest_updated.emit(q)

	for qid in completed_quests.keys():
		var q := _build_quest(qid)
		completed_quests[qid] = q
		quest_updated.emit(q)
