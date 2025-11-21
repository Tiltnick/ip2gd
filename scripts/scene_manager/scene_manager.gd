extends Node

var current_scene: Node
var next_spawn_id: String = "start"   # Name des Spawnpoints in der nächsten Szene


func _ready() -> void:
	# Aktuelle Szene merken (wie im Godot-Docs-Beispiel)
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(scene_path: String, spawn_id: String = "start") -> void:
	# Wird beim Szenenwechsel aufgerufen (z. B. von Doors)
	# Szene-Pfad in GameState speichern, damit SaveSystem weiß wo wir sind
	GameState.current_area_path = scene_path

	# Spawnpoint für die nächste Szene merken
	next_spawn_id = spawn_id

	# Deferred laden, damit Godot keine Probleme bekommt
	call_deferred("_deferred_goto_scene", scene_path)


func goto_main_menu() -> void:
	var root := get_tree().root

	# Alte Szene entfernen
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()

	# Neue Szene laden
	var packed: PackedScene = load("res://scenes/Menues/main_menu.tscn")
	var new_scene: Node = packed.instantiate()

	# Szene hinzufügen und als aktuelle setzen
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene

	# Spieler in der neuen Szene spawnen
	# (im MainMenu gibt es keinen Player, also hier nichts tun)


func _deferred_goto_scene(scene_path: String) -> void:
	var root := get_tree().root

	# Alte Szene entfernen
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()

	# Neue Szene laden
	var packed: PackedScene = load(scene_path)
	var new_scene: Node = packed.instantiate()

	# Szene hinzufügen und als aktuelle setzen
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene

	# Spieler in der neuen Szene spawnen
	_spawn_player_in_scene(new_scene)


func _spawn_player_in_scene(new_scene: Node) -> void:
	# Alte Player-Instanzen entfernen, falls welche existieren
	for p in get_tree().get_nodes_in_group("player"):
		p.queue_free()

	# SpawnPoints-Node in der Szene suchen
	var spawn_points := new_scene.get_node_or_null("SpawnPoints")
	if spawn_points == null:
		push_error("Keine 'SpawnPoints'-Node in Szene '%s' gefunden!" % new_scene.name)
		return

	# Spawnpoint anhand des Namens aus dem SceneManager holen
	var spawn: Node2D = spawn_points.get_node_or_null(next_spawn_id)
	if spawn == null:
		# Fallback: "start"-Spawnpoint
		spawn = spawn_points.get_node_or_null("start")
		if spawn == null:
			push_error("Kein passender Spawnpoint in Szene '%s' gefunden!" % new_scene.name)
			return

	# Spieler-Szene laden und instanzieren
	var packed_player: PackedScene = load("res://scenes/Character/main_character.tscn")
	var player: Node2D = packed_player.instantiate()

	# Spieler an Spawnposition setzen
	player.global_position = spawn.global_position

	# Gespeicherte Position überschreibt Spawnpoint, falls aus Save geladen
	if GameState.use_saved_position:
		player.global_position = GameState.player_position
		GameState.use_saved_position = false

	new_scene.add_child(player)

	# Kamera der neuen Player-Instanz aktivieren
	var cam := player.get_node_or_null("Camera2D")
	if cam:
		cam.make_current()
