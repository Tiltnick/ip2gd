extends Node

# Speicherort
const SAVE_PATH := "user://savegame.json"

# Autosave Time
const AUTOSAVE_INTERVAL := 120.0
var autosave_timer: Timer


func _ready() -> void:
	# Timer für autosaves
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.one_shot = false
	autosave_timer.autostart = true
	add_child(autosave_timer)
	autosave_timer.timeout.connect(_on_autosave_timeout)


func _on_autosave_timeout() -> void:
	# Nur im Spiel speichern wenn player da ist
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	save_game()
	print("Autosave durchgeführt")

# Daten werden aus GameState geladen
func save_game() -> void:
	# zuerst aktuelle Spielerposition (falls vorhanden) in GameState übernehmen
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player := players[0]
		GameState.player_position = player.global_position

	var data := GameState.to_dict()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Konnte Save-Datei nicht öffnen: " + SAVE_PATH)
		return

	file.store_string(JSON.stringify(data))
	# Bestätigt Speicherstand
	GameState.has_save = true


# Checkt ob Speicherstand existiert -> bool
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("Keine Save-Datei gefunden: " + SAVE_PATH)
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
	
	# Quests
	if has_node("/root/QuestManager"):
		get_node("/root/QuestManager").rebuild_from_gamestate()

	# Speicherstand existiert
	GameState.has_save = true
	# beim nächsten Szenenwechsel gespeicherte Position benutzen
	GameState.use_saved_position = true

	# Sprache nach dem Laden erneut anwenden
	if has_node("/root/LanguageManager"):
		get_node("/root/LanguageManager").apply_language()

	print("Spiel geladen von: ", SAVE_PATH)
	return true
