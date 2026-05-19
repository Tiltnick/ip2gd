extends Control

@onready var avatar_grid = $MarginContainer/VBoxContainer/TopSection/AvatarGrid

@onready var username_line_edit = $MarginContainer/VBoxContainer/FormSection/UsernameField/MarginContainer/HBoxContainer/UsernameLineEdit
@onready var bio_line_edit = $MarginContainer/VBoxContainer/FormSection/BioField/MarginContainer/HBoxContainer/BioLineEdit

@onready var save_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/SavingChangesButton
@onready var exit_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/ExitWithoutSavingButton

signal back_pressed
signal profile_saved

var selected_profile_picture: String = ""


func _ready():
	_spawn_dummy_profile_pictures()


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


func _spawn_dummy_profile_pictures():
	for child in avatar_grid.get_children():
		child.queue_free()

	for i in 12:
		var picture = preload("res://scenes/Spacegram/ProfilePictureOption.tscn").instantiate()
		avatar_grid.add_child(picture)


func _on_saving_changes_button_pressed() -> void:
	var display_name: String = username_line_edit.text.strip_edges()
	var bio: String = bio_line_edit.text.strip_edges()

	if display_name.is_empty():
		print("Display Name darf nicht leer sein.")
		return

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
		print("Profil konnte nicht gespeichert werden: ", result.error)


func _on_exit_without_saving_pressed():
	back_pressed.emit()
