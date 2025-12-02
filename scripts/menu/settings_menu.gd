extends Control
@onready var graphics: Button = $Panel/VBoxContainer/Graphics
@onready var controls: Button = $Panel/VBoxContainer/Controls
@onready var graphics_menu: HBoxContainer = $HBoxContainer
@onready var control_menu: GridContainer = $GridContainer
@onready var sound: Button = $Panel/VBoxContainer/Sound
@onready var sound_menu: VBoxContainer = $VBoxContainer



func _on_close_button_pressed() -> void:
	var scene = get_tree().current_scene
	var path = scene.scene_file_path
	get_tree().paused = false
	Visibility_Button.update_visibility(path)
	SettingsButton.show()
	SettingsMenu.hide()

func _on_controls_pressed() -> void:
	control_menu.show()
	graphics_menu.hide()
	sound_menu.hide()
	graphics.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)


func _on_graphics_pressed() -> void:
	graphics_menu.show()
	control_menu.hide()
	sound_menu.hide()
	controls.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)

func _on_sound_pressed() -> void:
	sound_menu.show()
	graphics_menu.hide()
	control_menu.hide()
	controls.set_pressed_no_signal(false)
	graphics.set_pressed_no_signal(false)
	
