extends Node2D

@onready var tutorial := $Tutorial_UI

func _ready() -> void:
	var cam = get_node_or_null("SceneCamera")
	if cam:
		cam.limit_left = -312
		cam.limit_right = 497
		cam.limit_top = -155
		cam.limit_bottom = 300
		_write_map_bounds(cam)

	if not GameState.puzzle_state.get("wakeup_done", false):
		GameState.puzzle_state["wakeup_done"] = true
		DialogManager.start_dialog("res://dialog/innerMonologue/wakeup.json")

		await DialogManager.dialog_finished
		QuestManager.add_quest("quest_1")
		tutorial.visible = true

func _write_map_bounds(cam: Camera2D) -> void:
	const PATH := "user://analytics/map_bounds.json"
	var all_bounds: Dictionary = {}
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				all_bounds = parsed
	all_bounds[scene_file_path] = {
		"limit_left": cam.limit_left,
		"limit_right": cam.limit_right,
		"limit_top": cam.limit_top,
		"limit_bottom": cam.limit_bottom,
	}
	var f2 := FileAccess.open(PATH, FileAccess.WRITE)
	if f2:
		f2.store_string(JSON.stringify(all_bounds))
