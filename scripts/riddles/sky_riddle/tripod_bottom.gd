extends Interactable

@export_file("*.tscn")
var sky_scene_path: String = ""

@export var required_item_id: String = "telescope1"

# Reihenfolge wichtig
const NO_TELESCOPE_FLOW := [
	{
		"flag": "tripod_no_telescope_seen",
		"path": "res://dialog/innerMonologue/tripod_without_telescope.json",
	},
]

const NO_TELESCOPE_END := "res://dialog/innerMonologue/tripod_without_telescope_end.json"


func interact() -> void:
	SfxPlayer.ui_click_sound()
	QuestManager.add_quest("quest_5")
	if not _has_required_item():
		var dialog_path := _get_no_telescope_dialog()
		if dialog_path != "":
			DialogManager.start_dialog(dialog_path)
		return

	_go_to_sky_scene()


func _get_no_telescope_dialog() -> String:
	for step in NO_TELESCOPE_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step["path"]
	return NO_TELESCOPE_END


func _go_to_sky_scene() -> void:
	GameState.return_scene_path = get_tree().current_scene.scene_file_path

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		GameState.player_position = player.global_position
		GameState.use_saved_position = true

	SceneManager.goto_scene(sky_scene_path, "start")


func _has_required_item() -> bool:
	# Du hast required_item_id exportiert; wenn du lieber hardcoded "telescope" willst,
	# kannst du hier wieder .has("telescope") benutzen.
	return hotbarglobal.inventory_items.has("telescope")
