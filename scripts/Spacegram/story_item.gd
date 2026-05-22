extends VBoxContainer

@onready var icon = $IconFrame/Icon
@onready var username_label = $Label

const DEFAULT_AVATAR := preload("res://assets/Spacegram/posts/profile_pictures/avatar_01.png")

signal story_pressed(profile_data)

var profile_data: Dictionary = {}


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func setup(new_profile_data: Dictionary) -> void:
	profile_data = new_profile_data

	var display_name: String = str(profile_data.get("display_name", "User"))
	var profile_picture: String = str(profile_data.get("profile_picture", ""))

	username_label.text = display_name

	if not profile_picture.is_empty() and ResourceLoader.exists(profile_picture):
		icon.texture = load(profile_picture)
	else:
		icon.texture = DEFAULT_AVATAR


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		story_pressed.emit(profile_data)
