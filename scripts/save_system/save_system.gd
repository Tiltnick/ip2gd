extends Node

# Speicherort
const SAVE_PATH := "user://savegame.json"

# Daten werden aus GameState geladen
func save_game() -> void:
	var data := GameState.to_dict()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Konnte Save-Datei nicht öffnen: " + SAVE_PATH)
		return

	file.store_string(JSON.stringify(data))
	# Besitzt Speicherstand
	GameState.has_save = true
	print("Game saved to: ", SAVE_PATH)

# Checkt ob Speicherstand existiert -> bool
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Keine Save-Datei vorhanden.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Konnte Save-Datei nicht zum Lesen öffnen: " + SAVE_PATH)
		return false

# json lesen
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("JSON Parse Error: " + json.get_error_message())
		return false

# Daten zurück in die GameState
	var data: Dictionary = json.data
	GameState.from_dict(data)
# Speicherstand existiert
	GameState.has_save = true

	print("Game loaded from: ", SAVE_PATH)
	return true
