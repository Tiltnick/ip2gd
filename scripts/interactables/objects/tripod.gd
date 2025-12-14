extends Interactable

@export var sky_scene_path: String = "res://scenes/Riddles/sky_puzzle/star_image_1.tscn"
@export var required_item_id: String = "telescope" # anpassen an deine ID

func interact() -> void:
	if not _has_telescope():
		print("Du brauchst ein Teleskop!")
		return

	# 1) Rückkehr-Szene merken
	GameState.return_scene_path = get_tree().current_scene.scene_file_path

	# 2) Spielerposition merken (damit du exakt da wieder auftauchst)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		GameState.player_position = player.global_position
		GameState.use_saved_position = true

	# 3) Wechsel in die Sky-Szene über deinen SceneManager
	SceneManager.goto_scene(sky_scene_path, "start")
	# spawn_id ist egal, weil use_saved_position=true dich exakt zurücksetzt

func _has_telescope() -> bool:
	
	return true
