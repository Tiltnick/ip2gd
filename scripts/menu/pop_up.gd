extends Control
@onready var color_rect: ColorRect = $ColorRect
@onready var yes_button: Button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/YesButton
@onready var no_button: Button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/NoButton
@onready var header: Label = $ColorRect/Panel/VBoxContainer3/START_GAME

var yes_callback: Callable = Callable()
var no_callback: Callable = Callable()

func open(text: String, yes_func: Callable):
	play_ui_sound()
	header.text = text
	yes_callback = yes_func
	SettingsButton.hide()
	show()

func close() -> void:
	play_ui_sound()
	hide()
	SettingsButton.show()


func _on_yes_button_pressed() -> void:
	play_ui_sound()
	if yes_callback.is_valid():
		yes_callback.call()
		close()
		


func _on_no_button_pressed() -> void:
	play_ui_sound()
	close()
	SettingsButton.show()


func play_ui_sound():
	WorldAudioManager.play_sfx(load("res://assets/sound/sfx/ui_sound.mp3"))
