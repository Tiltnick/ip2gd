extends Interactable

@export_file("*.tscn")
var sky_scene_path: String = ""

@export var required_item_id: String = "telescope1"

@export var tripod_id: String = "tripod_2"

# Reihenfolge wichtig
const NO_TELESCOPE_FLOW := [
	{
		"flag": "tripod_no_telescope_seen",
		"path": "res://dialog/innerMonologue/tripod_without_telescope.json",
	},
]

const NO_TELESCOPE_END := "res://dialog/innerMonologue/tripod_without_telescope_end.json"

const DONE_WITH_TELESCOPE_DIALOG := "res://dialog/innerMonologue/done_with_telescope.json"
const TELESCOPE_USED_FLAG := "telescope_consumed_after_statue"


func interact() -> void:
	SfxPlayer.ui_click_sound()
	QuestManager.add_quest("quest_5")

	# wenn teleskop vorhanden
	if _has_required_item():
		print("Tripod interact:", tripod_id)
		TripodManager.mark_interacted(tripod_id)
		_go_to_sky_scene()
		return

	# wenn teleskop verbraucht
	if bool(GameState.puzzle_state.get(TELESCOPE_USED_FLAG, false)):
		DialogManager.start_dialog(DONE_WITH_TELESCOPE_DIALOG)
		return

	# wenn noch kein teleskop eingesammelt
	var dialog_path := _get_no_telescope_dialog()
	if dialog_path != "":
		DialogManager.start_dialog(dialog_path)

#func interact() -> void:
	#SfxPlayer.ui_click_sound()
	#if not _has_required_item():
		#var dialog_path := _get_no_telescope_dialog()
		#if dialog_path != "":
			#DialogManager.start_dialog(dialog_path)
		#return
#
	#_go_to_sky_scene()


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
