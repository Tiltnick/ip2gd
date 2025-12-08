extends Node

var current_scene: Node
var next_spawn_id: String = "start"   # Name des Spawnpoints in der nächsten Szene


func _ready() -> void:
	# Szenen merken speichern in curren_scenee
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

# Szenenwechsel: pfad zur szene, Spawnpoints
func goto_scene(scene_path: String, spawn_id: String = "start") -> void:
	# Zielscene in Gamestate
	GameState.current_area_path = scene_path

	# Spawn für die nächste scene
	next_spawn_id = spawn_id
	
	# 1. Fade starten
	TransitionAreaFade.transition()

	# 2. Warten bis der Bildschirm komplett schwarz ist
	await TransitionAreaFade.transition_finished

	# Deferred laden steht so im docs
	call_deferred("_deferred_goto_scene", scene_path)


func goto_main_menu() -> void:
	var root := get_tree().root

	# Alte scene entfernen
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()

	# Neue scene laden laden
	var packed: PackedScene = load("res://scenes/Menues/main_menu.tscn")
	var new_scene: Node = packed.instantiate()

	# Scene als aktuelle setzen
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene


func _deferred_goto_scene(scene_path: String) -> void:
	var root := get_tree().root

	# Alte scene entfernen
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()

	# Neue scene laden
	var packed: PackedScene = load(scene_path)
	var new_scene: Node = packed.instantiate()

	# Scene als aktuelle setzen
	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene

	# Spieler in der neuen scene spawnen
	_spawn_player_in_scene(new_scene)
	


func _spawn_player_in_scene(new_scene: Node) -> void:
	# Player entfernen falls welche existieren
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
		# Falls es kein Spawnpoint gibt zu start
		spawn = spawn_points.get_node_or_null("start")
		if spawn == null:
			push_error("Kein passender Spawnpoint in Szene '%s' gefunden!" % new_scene.name)
			return

	# Spieler scene laden und instanzieren
	var packed_player: PackedScene = load("res://scenes/Character/main_character.tscn")
	var player: Node2D = packed_player.instantiate()

	# Spieler an Spawnposition setzen
	player.global_position = spawn.global_position

	# Falls es eine Position gibt aus der Gamestate diese nehmen bei resume
	if GameState.use_saved_position:
		player.global_position = GameState.player_position
		GameState.use_saved_position = false

	new_scene.add_child(player)

	# Wenn es eine SceneCamera gibt diese nehmen
	var scene_camera := new_scene.get_node_or_null("SceneCamera")
	if scene_camera and scene_camera is Camera2D:
		scene_camera.make_current()
	else:
		var cam := player.get_node_or_null("Camera2D")
		if cam:
			cam.make_current()
			if new_scene.has_method("configure_camera"):
				new_scene.call("configure_camera", cam)
				
	var point_light := new_scene.get_node_or_null("Field_of_view") as PointLight2D
	if point_light:
		point_light.reparent(player, true)
		point_light.position = Vector2.ZERO


	if GameState.should_play_intro_dialog:
		GameState.should_play_intro_dialog = false
		DialogManager.start_dialog("res://dialog/spaceship/wakeup.json")
