extends Node2D

func _ready() -> void:
		if not GameState.puzzle_state.get("flashlight", true):
			DialogManager.start_dialog("res://dialog/innerMonologue/entering_sams_cave.json")
		else:
			pass
			
func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -720
	cam.limit_right = 750
	cam.limit_top = -775
	cam.limit_bottom = 200
