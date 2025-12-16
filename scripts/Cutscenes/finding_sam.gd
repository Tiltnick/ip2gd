extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.start_dialog("res://dialog/innerMonologue/discovering_sams_body.json")
	
#func exit_scene() -> void:
	#if GameState.return_scene_path != "":
		#SceneManager.goto_scene(GameState.return_scene_path, "start")
	#else:
		#print("Kein return_scene_path gesetzt!")
