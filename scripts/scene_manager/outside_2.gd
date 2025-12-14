extends Node2D

func _ready() -> void:
	
	BgmPlayer.bgm_outside2()
	# Einmaliger innerer Monolog in Outside2
	if not GameState.puzzle_state.get("outside2_monologue_done", false):
		GameState.puzzle_state["outside2_monologue_done"] = true
		DialogManager.start_dialog("res://dialog/innerMonologue/entering_outside_2.json")


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -755
	cam.limit_right = -1
	cam.limit_top = -700
	cam.limit_bottom = 350
