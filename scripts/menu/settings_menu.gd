extends Control
@onready var graphics: Button = $Panel/VBoxContainer/Graphics
@onready var h_box_container: HBoxContainer = $Panel/HBoxContainer
@onready var grid_container: GridContainer = $Panel/GridContainer
@onready var controls: Button = $Panel/VBoxContainer/Controls



func _on_close_button_pressed() -> void:
	var scene = get_tree().current_scene
	var path = scene.scene_file_path
	get_tree().paused = false
	Visibility_Button.update_visibility(path)
	SettingsButton.show()
	SettingsMenu.hide()

func _on_controls_pressed() -> void:
	grid_container.show()
	h_box_container.hide()
	graphics.set_pressed_no_signal(false)


func _on_graphics_pressed() -> void:
	h_box_container.show()
	grid_container.hide()
	controls.set_pressed_no_signal(false)
