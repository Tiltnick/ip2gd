extends Area2D
class_name DoorArea

@export_file("*.tscn")
var target_scene_path: String = ""

@export
var target_spawn_id: String = "start"

@export 
var required_group: String = "player"

@export var required_items: Array[String] = []

@export_file("*.json")
var missing_items_dialog_json: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if required_group != "" and not body.is_in_group(required_group):
		return

	if target_scene_path == "":
		push_warning("DoorArea '%s' hat keinen target_scene_path gesetzt." % name)
		return

	if required_items.size() > 0:
		if not _player_has_all_items(body):
			_show_missing_items_dialog()
			return
			
	# Szenenwechsel über den SceneManager
	SceneManager.goto_scene(target_scene_path, target_spawn_id)
	
func _player_has_all_items(player: Node, ) -> bool:
	var picked_items := GameState.picked_items
	if typeof(picked_items) != TYPE_ARRAY:
		return false

	for item_id in required_items:
		if not picked_items.has(item_id):
			return false
			
	return true


func _show_missing_items_dialog() -> void:
	DialogManager.start_dialog(missing_items_dialog_json)
