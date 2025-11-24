extends Control
@onready var color_rect: ColorRect = $ColorRect
@onready var yes_button: Button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/YesButton
@onready var no_button: Button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/NoButton
@onready var header: Label = $ColorRect/Panel/VBoxContainer3/Label

var yes_callback: Callable = Callable()
var no_callback: Callable = Callable()

func open(text: String, yes_func: Callable):
	header.text = text
	yes_callback = yes_func
	SettingsButton.hide()
	show()

func close() -> void:
	hide()
	SettingsButton.show()


func _on_yes_button_pressed() -> void:
	if yes_callback.is_valid():
		yes_callback.call()
		close()
		DialogManager.start_dialog("res://dialog/spaceship/wakeup.json")


func _on_no_button_pressed() -> void:
	close()
	SettingsButton.show()
