extends Control

func _ready() -> void:
	DialogManager.start_dialog("res://dialog/innerMonologue/discovering_sams_body.json")
	await DialogManager.dialog_finished
	exit_scene()
	QuestManager.complete_quest("quest_4") # find sam

func exit_scene() -> void:
	if GameState.return_scene_path != "":
		SceneManager.goto_scene(GameState.return_scene_path, "from_finding_sam")
	else:
		print("Kein return_scene_path gesetzt!")
