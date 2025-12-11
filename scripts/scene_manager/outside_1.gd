extends Node2D

func _ready() -> void:
	# Einmaliger innerer Monolog direkt nach dem Verlassen des Raumschiffs
	if GameState.puzzle_state.get("ship_exit_monologue_pending", false):
		# Flag sofort verbr, damit es nur einmal passiert
		GameState.puzzle_state["ship_exit_monologue_pending"] = false

		DialogManager.start_dialog("res://dialog/innerMonologue/exiting_spaceship.json")


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -440
	cam.limit_right = 425
	cam.limit_top = -275
	cam.limit_bottom = 270
