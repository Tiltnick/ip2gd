extends Node
#scenes the button needs to be hidden
var hidden_in_scenes = [
"res://scenes/Menues/diary_menu.tscn",
"res://scenes/Menues/main_menu.tscn",
"res://scenes/Menues/PopUp.tscn",
"res://scenes/Menues/saving_menu.tscn",
"res://scenes/hotbar/hotbar.tscn"

	
]
var _last_path = ""

func update_visibility(path: String):
	if path in hidden_in_scenes:
		GlobalMenuButton.hide()
	#checking if diary is collected 
	elif GameState.puzzle_state.has("spaceship_diary"):
		GlobalMenuButton.show()


func _process(delta: float) -> void:
	var scene = get_tree().current_scene
	var path = scene.scene_file_path
		#scene could be in between two scnenes null, while switching to new scene -> could crash
	if scene == null:
		return
	if path != _last_path:
		_last_path = path
		update_visibility(path)
