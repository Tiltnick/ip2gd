extends Control

const START_SCENE: PackedScene = preload("res://scenes/Menues/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.start_dialog("res://dialog/CutScenes/ending_scene.json")
	await DialogManager.dialog_finished
	await transition()
	exit_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func exit_game():
	get_tree().change_scene_to_packed(START_SCENE)
	pass

func transition():
	TransitionAreaFade.transition()
	await TransitionAreaFade.transition_finished
