extends Node
#scenes the button needs to be hidden
var hidden_in_scenes = [
"res://scenes/Menues/diary_menu.tscn",
"res://scenes/Menues/main_menu.tscn",
"res://scenes/Menues/PopUp.tscn",
"res://scenes/Menues/saving_menu.tscn"
	
]
var _last_path = ""

func update_visibility(path: String):
	#TODO proving if diary is in inventory 
	if path in hidden_in_scenes:
		GlobalMenuButton.hide()
	else:
		GlobalMenuButton.show()


func _process(delta: float) -> void:
	#scene culd be in between two scnenes null, while switching to new scene
	var scene = get_tree().current_scene
	if scene == null:
		return
	
	var path = scene.scene_file_path
	if path != _last_path:
		_last_path = path
		update_visibility(path)
