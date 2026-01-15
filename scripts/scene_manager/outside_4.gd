extends Node2D

func _ready() -> void:
	pass


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -449
	cam.limit_right = 432
	cam.limit_top = -289
	cam.limit_bottom = 254
