extends Node2D

func _ready() -> void:
	GameState.unlock_progress_key("outside_3_entered")
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

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if not GameState.puzzle_state.get("outside3_monologue_done", true):
			PopupManager.popup_spacegram()
