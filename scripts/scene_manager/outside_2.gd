extends Node2D

func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -755
	cam.limit_right = -1
	cam.limit_top = -700
	cam.limit_bottom = 300
