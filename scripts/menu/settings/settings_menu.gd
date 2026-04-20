extends Control
@onready var language: Button = $Panel/VBoxContainer/Graphics
@onready var controls: Button = $Panel/VBoxContainer/Controls
@onready var language_menu: HBoxContainer = $HBoxContainer
@onready var control_menu: GridContainer = $GridContainer
@onready var sound: Button = $Panel/VBoxContainer/Sound
@onready var sound_menu: VBoxContainer = $VBoxContainer
@onready var graphics: Button = $Panel/VBoxContainer/Graphics
@onready var graphic_menu: HBoxContainer = $GraphicsContainer



func _on_close_button_pressed() -> void:
	var scene = get_tree().current_scene
	var path = scene.scene_file_path
	get_tree().paused = false
	Visibility_Button.update_visibility(path)
	SettingsButton.show()
	SettingsMenu.hide()
	SfxPlayer.ui_click_sound()

func _on_controls_pressed() -> void:
	control_menu.show()
	language_menu.hide()
	sound_menu.hide()
	graphic_menu.hide()
	language.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)
	graphics.set_pressed_no_signal(false)
	SfxPlayer.ui_click_sound()

func _on_language_pressed() -> void:
	language_menu.show()
	control_menu.hide()
	sound_menu.hide()
	graphic_menu.hide()
	controls.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)
	graphics.set_pressed_no_signal(false)
	SfxPlayer.ui_click_sound()
	
func _on_sound_pressed() -> void:
	sound_menu.show()
	language_menu.hide()
	control_menu.hide()
	graphic_menu.hide()
	controls.set_pressed_no_signal(false)
	language.set_pressed_no_signal(false)
	graphics.set_pressed_no_signal(false)
	SfxPlayer.ui_click_sound()
	
func _on_graphics_pressed() -> void:
	graphic_menu.show()
	sound_menu.hide()
	language_menu.hide()
	control_menu.hide()
	controls.set_pressed_no_signal(false)
	language.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)
	SfxPlayer.ui_click_sound()

func _on_account_pressed():
	sound_menu.hide()
	language_menu.hide()
	control_menu.hide()
	graphic_menu.hide()
	controls.set_pressed_no_signal(false)
	language.set_pressed_no_signal(false)
	sound.set_pressed_no_signal(false)
	graphics.set_pressed_no_signal(false)
	SfxPlayer.ui_click_sound()

func _on_h_slider_sound_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SfxPlayer.ui_click_sound()
