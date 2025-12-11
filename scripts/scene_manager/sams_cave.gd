extends Node2D

func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -720
	cam.limit_right = 750
	cam.limit_top = -775
	cam.limit_bottom = 126
