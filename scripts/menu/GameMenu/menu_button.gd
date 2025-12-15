extends Node

#scenes in which the button needs to be hidden
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

func _process(_delta: float) -> void:
	var scene = get_tree().current_scene
	if scene == null:
		return

	var path = scene.scene_file_path

	if path != _last_path:
		_last_path = path
		update_visibility(path)


func _on_pressed():
	# Öffnet das MainMenu innerhalb der Szene
	var menu = get_tree().current_scene.get_node("CanvasLayer") # anpassen falls CanvasLayer anders heißt
	menu.visible = true
	get_tree().paused = true
