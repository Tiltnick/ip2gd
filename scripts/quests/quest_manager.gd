extends Node

signal quest_added(quest_data)
signal quest_completed(quest_data)

var current_quests := {}
var completed_quests := {}

var quest_data: Dictionary = {}

func _ready() -> void:
	_load_quest_json()
	rebuild_from_gamestate()

func add_quest(id: String):
	
	# Quest existiert nicht in JSON
	if not quest_data.has(id):
		push_error("Quest ID not found in JSON: " + id)
		return

	# Quest bereits gestartet / abgeschlossen
	if GameState.quest_state.has(id):
		return

	GameState.quest_state[id] = "started"

	var q = quest_data[id]
	var lang = TranslationServer.get_locale().substr(0, 2)

	var title_key = "quest_title_" + lang
	var desc_key = "quest_description_" + lang

	var quest = {
		"id": id,
		"title": q.get(title_key, ""),
		"description": q.get(desc_key, "")
	}

	current_quests[id] = quest
	emit_signal("quest_added", quest)
	
	_show_quest_popup(quest)

func complete_quest(id: String):
	if not current_quests.has(id): return

	GameState.quest_state[id] = "completed"

	var quest = current_quests[id]
	current_quests.erase(id)
	completed_quests[id] = quest
	emit_signal("quest_completed", quest)
	
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
	for id in GameState.quest_state:
		var state = GameState.quest_state[id]

		if state == "started":
			add_quest(id)

		elif state == "completed":
			if not quest_data.has(id):
				continue

			var q = quest_data[id]
			var lang = TranslationServer.get_locale().substr(0, 2)

			var quest = {
				"id": id,
				"title": q.get("quest_title_" + lang, ""),
				"description": q.get("quest_description_" + lang, "")
			}

			completed_quests[id] = quest
			emit_signal("quest_completed", quest)

func _show_quest_popup(quest):
	var lang = TranslationServer.get_locale().substr(0, 2)
	#if save_id == "quest":
		#GameState.puzzle_state[save_id] = true
	if lang == "de":
		PopupManager.popup_quest_de(quest["title"])
	elif lang == "en":
		PopupManager.popup_quest_en(quest["title"])
