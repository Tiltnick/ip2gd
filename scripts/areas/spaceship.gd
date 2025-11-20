extends Node2D

func _ready() -> void:
	GameState.current_area_path = get_scene_file_path()
