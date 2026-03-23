extends Node2D

func _ready() -> void:
	BgmPlayer.bgm_outside3()
	if not GameState.puzzle_state.get("outside3_monologue_done", false):
		GameState.puzzle_state["outside3_monologue_done"] = true
		DialogManager.start_dialog("res://dialog/mushrooms/outside_3_begin.json")
	
	if not GameState.map_state.get("outside3_map", false):
		GameState.map_state["outside3_map"] = true

func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = 35
	cam.limit_right = 800
	cam.limit_top = -735
	cam.limit_bottom = 300
	_write_map_bounds(cam)

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if not GameState.puzzle_state.get("outside3_monologue_done", true):
			PopupManager.popup_spacegram()

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
