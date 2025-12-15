extends Node2D

func _ready() -> void:
	pass


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -750
	cam.limit_right = -205
	cam.limit_top = -600
	cam.limit_bottom = -5
