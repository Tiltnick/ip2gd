extends Node2D

func _ready() -> void:
	if not GameState.puzzle_state.get("spaceship_room_done", false):
		GameState.puzzle_state["spaceship_room_done"] = true
		DialogManager.start_dialog("res://dialog/spaceship/door_opened.json")


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -750
	cam.limit_right = -205
	cam.limit_top = -600
	cam.limit_bottom = -5
