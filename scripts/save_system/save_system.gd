extends Node

# Autosave Time
const AUTOSAVE_INTERVAL := 120.0
var autosave_timer: Timer


func _ready() -> void:
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.one_shot = false
	autosave_timer.autostart = true
	add_child(autosave_timer)
	autosave_timer.timeout.connect(_on_autosave_timeout)


func _on_autosave_timeout() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	await save_game()
	print("Autosave durchgeführt")


# über nakama jetzt
func save_game() -> void:
	if not NakamaManager.is_logged_in():
		print("Nicht eingeloggt → kein Save möglich")
		return

	# Spielerposition übernehmen
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player := players[0]
		GameState.player_position = player.global_position

	var data := GameState.to_dict()
	var json_data := JSON.stringify(data)

	var write = NakamaWriteStorageObject.new(
		"savegame",   # collection
		"main",       # key
		2,            # read
		1,            # write
		json_data,
		""
	)

	var result = await NakamaManager.client.write_storage_objects_async(
	NakamaManager.session,
	[write]
)

	if result.is_exception():
		print("Save Fehler:", result)
		return

	GameState.has_save = true
	print("Save erfolgreich (online)")


# auch über nakama
func load_game() -> bool:
	if not NakamaManager.is_logged_in():
		print("Nicht eingeloggt → kein Load möglich")
		return false

	var objects = await NakamaManager.client.read_storage_objects_async(
	NakamaManager.session,
	[
		NakamaStorageObjectId.new(
			"savegame",
			"main",
			NakamaManager.session.user_id
		)
	]
)

	if objects.is_exception():
		print("Load Fehler:", objects)
		return false

	if objects.objects.is_empty():
		print("Kein Save vorhanden → neues Spiel")
		return false

	var json_string = objects.objects[0].value
	var data = JSON.parse_string(json_string)

	GameState.from_dict(data)

	# Quests rebuild
	if has_node("/root/QuestManager"):
		get_node("/root/QuestManager").rebuild_from_gamestate()

	GameState.has_save = true
	GameState.use_saved_position = true

	# Sprache neu anwenden
	if has_node("/root/LanguageManager"):
		get_node("/root/LanguageManager").apply_language()

	print("Save geladen (online)")
	return true
