extends Control
@onready var sound: Button = $Panel/VBoxContainer/Sound
@onready var margin_container: MarginContainer = $MarginContainer


func _on_close_button_pressed() -> void:
	var scene = get_tree().current_scene
	var path = scene.scene_file_path
	get_tree().paused = false
	Visibility_Button.update_visibility(path)
	SettingsButton.show()
	SettingsMenu.hide()


func _on_sound_pressed() -> void:
	pass
