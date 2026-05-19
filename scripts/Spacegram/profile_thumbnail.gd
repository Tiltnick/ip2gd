extends Control

signal thumbnail_pressed(post_data)

@onready var texture_rect = $TextureRect

var post_data: Dictionary = {}


func setup(new_post_data: Dictionary, image: Texture2D) -> void:
	post_data = new_post_data
	texture_rect.texture = image


func _ready():
	gui_input.connect(_on_gui_input)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		thumbnail_pressed.emit(post_data)
