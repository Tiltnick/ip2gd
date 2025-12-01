extends Node

# Merken in welcher Szene der Spieler zuletzt war
var current_area_path: String = "res://scenes/maps/spaceship.tscn"

var should_play_intro_dialog: bool = false

# Zustände speichern
var puzzle_state: Dictionary = {}

var has_save: bool = false

# Letzte Spielerposition
var player_position: Vector2 = Vector2.ZERO

var use_saved_position: bool = false

# Aufgehobene Items speichern
var picked_items: Array = []

# Puzzle-Items (Fix für deinen New Game Fehler)
var puzzle_items: Array = []

var sound_settings: Array = []


# Funktion -> Dic wird geupdated
func to_dict() -> Dictionary:
	return {
		"current_area_path": current_area_path,
		"puzzle_state": puzzle_state,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
		"picked_items": picked_items,
		"puzzle_items": puzzle_items,
		"sound_settings": sound_settings
	}
	


# Liest die geupdateten Daten aus
func from_dict(data: Dictionary) -> void:
	if data.has("current_area_path"):
		current_area_path = data["current_area_path"]

	if data.has("puzzle_state"):
		puzzle_state = data["puzzle_state"]

	if data.has("player_position"):
		var p = data["player_position"]
		if typeof(p) == TYPE_DICTIONARY and p.has("x") and p.has("y"):
			player_position = Vector2(p["x"], p["y"])

	if data.has("picked_items"):
		picked_items = data["picked_items"]

	if data.has("puzzle_items"):
		puzzle_items = data["puzzle_items"]
		
	if data.has("sound_settings"):
		sound_settings = data["sound_settings"]
