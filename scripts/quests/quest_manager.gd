extends Node

signal quest_added(quest_data)
signal quest_completed(quest_data)

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

func rebuild_from_gamestate():
	current_quests.clear()
	completed_quests.clear()

	for id in GameState.quest_state.keys():
		if not quest_data.has(id):
			continue

		var raw_state = GameState.quest_state[id]

		# 🔒 MIGRATION / SAFETY
		if typeof(raw_state) != TYPE_DICTIONARY:
			raw_state = {
				"status": str(raw_state),
				"is_new": false
			}
			GameState.quest_state[id] = raw_state

		var status: String = raw_state.get("status", "")
		var quest = _build_quest(id)

		if status == "started":
			current_quests[id] = quest
			quest_added.emit(quest)
		elif status == "completed":
			completed_quests[id] = quest
			quest_completed.emit(quest)


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

func add_quest(id: String):
	if not quest_data.has(id):
		return

	if not GameState.quest_state.has(id):
		GameState.quest_state[id] = {
			"status": "started",
			"is_new": true
		}


	GameState.quest_state[id] = {
		"status": "started",
		"is_new": true
	}

	var quest: Dictionary = _build_quest(id)
	current_quests[id] = quest
	
	quest_added.emit(quest) #Popup wird über signal aufgerufen

	SaveSystem.save_game()



func complete_quest(id: String):
	if not current_quests.has(id):
		return

	GameState.quest_state[id]["status"] = "completed"
	GameState.quest_state[id]["is_new"] = false

	var quest = current_quests[id]
	quest["is_new"] = false

	current_quests.erase(id)
	completed_quests[id] = quest

	quest_completed.emit(quest)
	
	SaveSystem.save_game()


func _build_quest(id: String) -> Dictionary:
	var q = quest_data[id]
	var lang = TranslationServer.get_locale().substr(0, 2)
	var state: Dictionary = GameState.quest_state.get(id, {})

	return {
		"id": id,
		"title": q.get("quest_title_" + lang, ""),
		"description": q.get("quest_description_" + lang, ""),
		"is_new": state.get("is_new", false),
		
		"needs_item": q.get("needs_item", "false") == "true",
		"icon_path": q.get("icon_path", "")
		}
	
	
