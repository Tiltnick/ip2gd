extends Node

# Merken in welcher Szene der Spieler zuletzt war
var current_area_path: String = "res://scenes/maps/spaceship.tscn"

# Zustände speichern z.B Diary
var puzzle_state: Dictionary = {}

var has_save: bool = false

# NEU: letzte bekannte Spielerposition
var player_position: Vector2 = Vector2.ZERO

# NEU: Nur zur Laufzeit – soll beim nächsten Spawn verwendet werden
var use_saved_position: bool = false


# Funktion -> Dic wird geupdated
func to_dict() -> Dictionary:
	return {
		"current_area_path": current_area_path,
		"puzzle_state": puzzle_state,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
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
