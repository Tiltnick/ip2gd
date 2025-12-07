extends Area2D
class_name DoorArea

@export_file("*.tscn")
var target_scene_path: String = ""

@export
var target_spawn_id: String = "start"   # Name des Spawnpoints in der Zielszene

@export 
var required_group: String = "player"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if required_group != "" and not body.is_in_group(required_group):
		return

	if target_scene_path == "":
		push_warning("DoorArea '%s' hat keinen target_scene_path gesetzt." % name)
		return

	# Szenenwechsel über den SceneManager
	SceneManager.goto_scene(target_scene_path, target_spawn_id)
