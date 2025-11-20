extends Node

# Merken in welcher Szene der Spieler zuletzt war
var current_area_path: String = "res://scenes/maps/spaceship.tscn"

# Zustände speichern z.B Diary
var puzzle_state: Dictionary = {}

var has_save: bool = false

# Funktion -> Dic wird geupdated
func to_dict() -> Dictionary:
	return {
		"current_area_path": current_area_path,
		"puzzle_state": puzzle_state,
	}

# Liest die geupdateten Daten aus
func from_dict(data: Dictionary) -> void:
	if data.has("current_area_path"):
		current_area_path = data["current_area_path"]

	if data.has("puzzle_state"):
		puzzle_state = data["puzzle_state"]
