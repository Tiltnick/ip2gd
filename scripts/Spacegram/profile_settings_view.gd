extends Control

@onready var avatar_grid = $MarginContainer/VBoxContainer/TopSection/AvatarGrid

signal back_pressed

func _ready():
	_spawn_dummy_profile_pictures()


func _spawn_dummy_profile_pictures():
	for i in 12:
		var picture = preload("res://scenes/Spacegram/ProfilePictureOption.tscn").instantiate()
		avatar_grid.add_child(picture)

func _on_exit_without_saving_pressed():
	back_pressed.emit()
