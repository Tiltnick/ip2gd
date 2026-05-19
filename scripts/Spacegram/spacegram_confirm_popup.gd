extends Control

signal decision_made(confirmed: bool)

@onready var confirm_label = $ColorRect/Panel/VBoxContainer3/ConfirmLabel
@onready var yes_button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/YesButton
@onready var no_button = $ColorRect/Panel/VBoxContainer3/HBoxContainer/NoButton


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	


func ask(message: String) -> bool:
	confirm_label.text = message
	visible = true
	
	var confirmed: bool = await decision_made
	
	visible = false
	return confirmed


func _on_yes_pressed() -> void:
	decision_made.emit(true)


func _on_no_pressed() -> void:
	decision_made.emit(false)
