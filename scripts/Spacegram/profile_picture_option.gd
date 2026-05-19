extends Control

signal avatar_selected(image_path: String)

@onready var profile_image = $ProfileImageFrame/ProfileImage

var image_path: String = ""


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func setup(new_image_path: String, texture: Texture2D) -> void:
	image_path = new_image_path
	profile_image.texture = texture


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		avatar_selected.emit(image_path)
