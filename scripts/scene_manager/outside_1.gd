extends Node2D

func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -440
	cam.limit_right = 425
	cam.limit_top = -275
	cam.limit_bottom = 270
