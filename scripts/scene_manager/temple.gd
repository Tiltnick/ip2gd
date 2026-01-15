extends Node2D

func _ready() -> void:
	pass


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -575
	cam.limit_right = 590
	cam.limit_top = -420
	cam.limit_bottom = 350
