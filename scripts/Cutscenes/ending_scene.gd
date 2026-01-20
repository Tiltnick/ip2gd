extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.start_dialog("res://dialog/CutScenes/ending_scene.json")
	await DialogManager.dialog_finished
	exit_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func exit_game():
	pass
