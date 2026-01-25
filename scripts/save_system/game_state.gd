extends Node

# Merken in welcher Szene der Spieler zuletzt war
var current_area_path: String = "res://scenes/maps/spaceship.tscn"

var should_play_intro_dialog: bool = false

# Zustände speichern
var puzzle_state: Dictionary = {}

var tutorial_done: bool = false

var dialog_state: Dictionary = {}

var map_state: Dictionary = {}
var quest_state: Dictionary = {}

var return_scene_path: String = ""

var has_save: bool = false

# Letzte Spielerposition
var player_position: Vector2 = Vector2.ZERO


var use_saved_position: bool = false

# Aufgehobene Items speichern
var picked_items: Array = []

# Puzzle-Items
var puzzle_items: Array = []

var sound_setting: float
var music_setting: float
# Sprache
var language: String = "en"

var display_mode: String = "fullscreen"


var inventory_slots: Array = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]
var hotbar_counts: Dictionary = {}
var hotbar_icon_override: Dictionary = {}


func start_dialog(dialog_id: String) -> void:
	# Dialog existiert
	if not dialog_state.has(dialog_id):
		dialog_state[dialog_id] = false


func finish_dialog(dialog_id: String) -> void:
	dialog_state[dialog_id] = true


func is_dialog_finished(dialog_id: String) -> bool:
	return dialog_state.get(dialog_id, false)


# Funktion -> Dic wird geupdated
func to_dict() -> Dictionary:
	return {
		"current_area_path": current_area_path,
		"puzzle_state": puzzle_state,
		"tutorial_done": tutorial_done,
		"dialog_state": dialog_state,
		"map_state": map_state,
		"quest_state": quest_state,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
		"picked_items": picked_items,
		"puzzle_items": puzzle_items,
		"music_setting": music_setting,
		"sound_setting": sound_setting,
		"language": language,
		"display_mode": display_mode,
		"inventory_slots": inventory_slots,
		"hotbar_counts": hotbar_counts,
		"hotbar_icon_override": hotbar_icon_override,

	}


# Liest die geupdateten Daten aus
func from_dict(data: Dictionary) -> void:
	if data.has("current_area_path"):
		current_area_path = data["current_area_path"]

	if data.has("puzzle_state"):
		puzzle_state = data["puzzle_state"]

	if data.has("dialog_state"):
		dialog_state = data["dialog_state"]

	if data.has("map_state"):
		map_state = data["map_state"]

	if data.has("display_mode"):
		display_mode = str(data["display_mode"])

	if data.has("quest_state"):
		quest_state = data["quest_state"]

	if data.has("player_position"):
		var p = data["player_position"]
		if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
			player_position = Vector2(p["x"], p["y"])

	if data.has("picked_items"):
		picked_items = data["picked_items"]

	if data.has("puzzle_items"):
		puzzle_items = data["puzzle_items"]
		
	if data.has("tutorial_done"):
		tutorial_done = bool(data["tutorial_done"])


	if data.has("sound_setting"):
		sound_setting = data["sound_setting"]
		push_warning(sound_setting)

	if data.has("music_setting"):
		music_setting = data["music_setting"]
		push_warning(music_setting)

	if data.has("language"):
		language = str(data["language"])
		TranslationServer.set_locale(language)
		
	if data.has("inventory_slots") and typeof(data["inventory_slots"]) == TYPE_ARRAY:
		inventory_slots = data["inventory_slots"]
	else:
		inventory_slots = [
			null, null, null, null,
			null, null, null, null,
			null, null, null, null,
			null, null, null, null
		]

	if data.has("hotbar_counts") and typeof(data["hotbar_counts"]) == TYPE_DICTIONARY:
		hotbar_counts = data["hotbar_counts"]
	else:
		hotbar_counts = {}

	if data.has("hotbar_icon_override") and typeof(data["hotbar_icon_override"]) == TYPE_DICTIONARY:
		hotbar_icon_override = data["hotbar_icon_override"]
	else:
		hotbar_icon_override = {}
