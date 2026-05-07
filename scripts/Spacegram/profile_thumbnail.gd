extends Control

signal thumbnail_pressed(post_data)

var post_data

func _ready():
	gui_input.connect(_on_gui_input)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		thumbnail_pressed.emit(post_data)
