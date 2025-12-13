extends Node2D

func _ready() -> void:
	pass


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = 35
	cam.limit_right = 800
	cam.limit_top = -700
	cam.limit_bottom = 300
