extends Interactable

@export_file("*.tscn")
var sky_scene_path: String = ""

@export var required_item_id: String = "telescope1"

func interact() -> void:
	if not _has_telescope():
		print("Du brauchst ein Teleskop!")
		return

	GameState.return_scene_path = get_tree().current_scene.scene_file_path
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		GameState.player_position = player.global_position
		GameState.use_saved_position = true

	SceneManager.goto_scene(sky_scene_path, "start")
	

func _has_telescope() -> bool:
	if hotbarglobal.inventory_items.has("telescope"):
		return true
	else:
		return false
