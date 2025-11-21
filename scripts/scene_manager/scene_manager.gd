extends Node

var current_scene: Node
var next_spawn_id: String = "start"   # Name des Spawnpoints in der nächsten Szene

func _ready() -> void:
	# Aktuelle Szene merken (wie im Godot-Docs-Beispiel)
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(scene_path: String, spawn_id: String = "start") -> void:
	# Von Türen etc. aufrufen:
	# SceneManager.goto_scene("res://outside_1.tscn", "from_spaceship")
	next_spawn_id = spawn_id
	call_deferred("_deferred_goto_scene", scene_path)


func _deferred_goto_scene(scene_path: String) -> void:
	var root := get_tree().root

	if current_scene:
		current_scene.queue_free()

	var packed: PackedScene = load(scene_path)
	var new_scene: Node = packed.instantiate()

	root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene
