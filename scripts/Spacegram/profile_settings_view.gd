extends Control

@onready var avatar_grid = $MarginContainer/VBoxContainer/TopSection/AvatarGrid
@onready var preview_image = $MarginContainer/VBoxContainer/TopSection/ProfileImageCenter/ProfileImageWrapper/ProfileImageFrame/ProfileImage

@onready var username_line_edit = $MarginContainer/VBoxContainer/FormSection/UsernameField/MarginContainer/HBoxContainer/UsernameLineEdit
@onready var bio_line_edit = $MarginContainer/VBoxContainer/FormSection/BioField/MarginContainer/HBoxContainer/BioLineEdit

@onready var save_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/SavingChangesButton
@onready var exit_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/ExitWithoutSavingButton
@onready var error_label = $MarginContainer/VBoxContainer/FormSection/UsernameErrorLabel

const PROFILE_PICTURE_OPTION_SCENE := preload("res://scenes/Spacegram/ProfilePictureOption.tscn")

const AVATAR_PATHS := [
	"res://assets/Spacegram/posts/profile_pictures/avatar_01.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_02.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_03.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_04.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_05.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_06.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_07.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_08.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_09.png",
	"res://assets/Spacegram/posts/profile_pictures/avatar_10.png"
]

signal back_pressed
signal profile_saved

var selected_profile_picture: String = ""
var avatar_options: Array = []

func _ready() -> void:
	error_label.visible = false
	username_line_edit.max_length = 12
	username_line_edit.text_changed.connect(_on_username_text_changed)
	_spawn_profile_picture_options()


func load_settings() -> void:
	if not NakamaManager.is_logged_in():
		print("ProfileSettingsView: Nicht eingeloggt.")
		return

	var result = await SpacegramApi.get_my_profile()

	if not result.success:
		print("ProfileSettingsView: Profil konnte nicht geladen werden: ", result.error)
		return

	if result.data == null:
		print("ProfileSettingsView: Keine Profildaten vorhanden.")
		return

	var profile_data: Dictionary = result.data

	username_line_edit.text = str(profile_data.get("display_name", ""))
	bio_line_edit.text = str(profile_data.get("bio", ""))

	selected_profile_picture = str(profile_data.get("profile_picture", ""))

	if not selected_profile_picture.is_empty() and ResourceLoader.exists(selected_profile_picture):
		preview_image.texture = load(selected_profile_picture)
	else:
		_set_default_avatar()
		
	_update_selected_avatar_ui()
	
	username_line_edit.release_focus()
	bio_line_edit.release_focus()


func _spawn_profile_picture_options() -> void:
	for child in avatar_grid.get_children():
		child.queue_free()

	avatar_options.clear()

	for avatar_path in AVATAR_PATHS:
		if not ResourceLoader.exists(avatar_path):
			print("Avatar nicht gefunden: ", avatar_path)
			continue

		var texture: Texture2D = load(avatar_path)

		var picture = PROFILE_PICTURE_OPTION_SCENE.instantiate()
		avatar_grid.add_child(picture)

		picture.setup(avatar_path, texture)
		picture.avatar_selected.connect(_on_avatar_selected)

		avatar_options.append(picture)


func _on_avatar_selected(image_path: String, option_node: Control) -> void:
	selected_profile_picture = image_path

	if ResourceLoader.exists(image_path):
		preview_image.texture = load(image_path)

	for option in avatar_options:
		option.set_selected(option == option_node)


func _set_default_avatar() -> void:
	if AVATAR_PATHS.is_empty():
		return

	var default_path: String = AVATAR_PATHS[0]

	if ResourceLoader.exists(default_path):
		selected_profile_picture = default_path
		preview_image.texture = load(default_path)

	_update_selected_avatar_ui()

func _on_saving_changes_button_pressed() -> void:
	var display_name: String = username_line_edit.text.strip_edges()
	var bio: String = bio_line_edit.text.strip_edges()

	hide_error()

	if display_name.is_empty():
		show_error("ERROR_DISPLAY_NAME_REQUIRED")
		return

	if display_name.length() > 12:
		show_error("ERROR_DISPLAY_NAME_TOO_LONG")
		return

	if selected_profile_picture.is_empty():
		_set_default_avatar()

	save_button.disabled = true

	var result = await SpacegramApi.update_my_profile(
		display_name,
		bio,
		selected_profile_picture
	)

	save_button.disabled = false

	if result.success:
		print("Profil gespeichert.")
		profile_saved.emit()
	else:
		var error: String = str(result.error)

		if error == "DISPLAY_NAME_TAKEN":
			show_error("ERROR_DISPLAY_NAME_TAKEN")
		elif error == "DISPLAY_NAME_TOO_LONG":
			show_error("ERROR_DISPLAY_NAME_TOO_LONG")
		elif error == "DISPLAY_NAME_REQUIRED":
			show_error("ERROR_DISPLAY_NAME_REQUIRED")
		else:
			show_error("ERROR_PROFILE_SAVE_FAILED")


func _on_exit_without_saving_pressed() -> void:
	back_pressed.emit()

func _update_selected_avatar_ui() -> void:
	for option in avatar_options:
		option.set_selected(option.image_path == selected_profile_picture)
		
func show_error(key: String) -> void:
	error_label.text = key
	error_label.visible = true


func hide_error() -> void:
	error_label.text = ""
	error_label.visible = false
	
func _on_username_text_changed(new_text: String) -> void:
	if new_text.length() >= 12:
		show_error("ERROR_DISPLAY_NAME_TOO_LONG")
	else:
		hide_error()
