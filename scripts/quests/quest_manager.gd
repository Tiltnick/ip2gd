extends Node

signal quest_added(quest_data)
signal quest_updated(quest_data)
signal quest_completed(quest_data)
signal quest_item_progressed(quest_data, item_id)

var current_quests := {}
var completed_quests := {}
var quest_data := {}

func _ready():
	_load_quest_json()
	rebuild_from_gamestate()

#func rebuild_from_gamestate():
	#current_quests.clear()
	#completed_quests.clear()
#
	#for id in GameState.quest_state.keys():
		#if not quest_data.has(id):
			#continue
#
		#var state_data: Dictionary = GameState.quest_state[id]
		#var status: String = state_data.get("status", "")
#
		#var quest = _build_quest(id)
#
		#if status == "started":
			#current_quests[id] = quest
			#quest_added.emit(quest)
#
		#elif status == "completed":
			#completed_quests[id] = quest
			#quest_completed.emit(quest)
#

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


#func rebuild_from_gamestate():
	#current_quests.clear()
	#completed_quests.clear()
#
	#for id in GameState.quest_state.keys():
		#if not quest_data.has(id):
			#continue
#
		#var raw_state = GameState.quest_state[id]
#
		## 🔒 MIGRATION / SAFETY
		#if typeof(raw_state) != TYPE_DICTIONARY:
			#raw_state = {
				#"status": str(raw_state),
				#"is_new": false
			#}
			#GameState.quest_state[id] = raw_state
#
		#var status: String = raw_state.get("status", "")
		#var quest = _build_quest(id)
#
		#if status == "started":
			#current_quests[id] = quest
			#quest_added.emit(quest)
		#elif status == "completed":
			#completed_quests[id] = quest
			#quest_completed.emit(quest)

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
				quest_added.emit(quest)
			"completed":
				completed_quests[id] = quest
				quest_completed.emit(quest)

#func add_quest(id: String):
	#if GameState.quest_state.has(id): #if not quest_data.has(id):
		#return
#
	#if not GameState.quest_state.has(id):
		#GameState.quest_state[id] = {
			#"status": "started",
			#"step": 0,
			#"is_new": true
		#}
#
	#GameState.quest_state[id] = {
		#"status": "started",
		#"is_new": true
	#}
#
	#var quest: Dictionary = _build_quest(id)
	#current_quests[id] = quest
	#quest_added.emit(quest) #Popup wird über signal aufgerufen
#
	#SaveSystem.save_game()

func add_quest(id: String):
	if GameState.quest_state.has(id):
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

#func update_quest(id: String):
	#if not current_quests.has(id):
		#return
#
	#var state = GameState.quest_state[id]
	#state["step"] += 1
	#state["is_new"] = true
#
	#var quest = _build_quest(id)
	#current_quests[id] = quest
#
	#quest_added.emit(quest)
	#SaveSystem.save_game()

func update_quest(id: String):
	if not current_quests.has(id):
		return

	var state = GameState.quest_state[id]
	state["step"] += 1
	state["is_new"] = true

	if state["step"] >= quest_data[id]["steps"].size():
		complete_quest(id)
		return

	var quest = _build_quest(id)
	current_quests[id] = quest
	quest_added.emit(quest)

	SaveSystem.save_game()


#func complete_quest(id: String):
	#if not current_quests.has(id):
		#return
#
	#GameState.quest_state[id]["status"] = "completed"
	#GameState.quest_state[id]["is_new"] = false
#
	#var quest = current_quests[id]
	#quest["is_new"] = false
#
	#current_quests.erase(id)
	#completed_quests[id] = quest
#
	#quest_completed.emit(quest)
	#
	#SaveSystem.save_game()

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

#func _build_quest(id: String) -> Dictionary:
	#var q = quest_data[id]
	#var lang = TranslationServer.get_locale().substr(0, 2)
	#var state: Dictionary = GameState.quest_state[id]
	#var step = state.get("step", 0)
#
	#var step_data = q["steps"][step]
#
	#return {
			#"id": id,
			#"step": step,
			#"title": step_data["title"][lang],
			#"description": step_data["description"][lang],
			#"is_new": state.get("is_new", false),
#
			#"needs_items": step_data.get("needs_items", []),
			#"spacegram_hint": step_data.get("spacegram_hint", false)
	#}
	#
	
	
func _build_quest(id: String) -> Dictionary:
	var q: Dictionary = quest_data[id]
	var state: Dictionary = GameState.quest_state.get(id, {})
	var lang = TranslationServer.get_locale().substr(0, 2)

	var step_data: Dictionary = q["steps"][0] # ✅ immer erster

	return {
		"id": id,
		"title": step_data.get("title", {}).get(lang, ""),
		"description": step_data.get("description", {}).get(lang, ""),
		"is_new": state.get("is_new", false),
		"needs_items": step_data.get("needs_items", []),
		"spacegram_hint": step_data.get("spacegram_hint", false)
	}


func on_item_picked(item_id: String) -> void:
	# nur aktive quests
	for qid in current_quests.keys():
		var state: Dictionary = GameState.quest_state.get(qid, {})
		if state.get("status", "") != "started":
			continue

		var quest := _build_quest(qid)
		var needed: Array = quest.get("needs_items", [])
		if needed.is_empty():
			continue

		# braucht diese quest das item?
		if not needed.has(item_id):
			continue

		# spam-schutz
		if not state.has("notified_items"):
			state["notified_items"] = []
		if state["notified_items"].has(item_id):
			continue

		# ✅ merken + signal feuern
		state["notified_items"].append(item_id)
		GameState.quest_state[qid] = state

		quest_item_progressed.emit(quest, item_id)
		SaveSystem.save_game()


func _are_all_items_collected(quest: Dictionary) -> bool:
	for item_id in quest.get("needs_items", []):
		if not GameState.picked_items.has(item_id):
			return false
	return true
