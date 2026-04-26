extends Control

@onready var post_grid = $ScrollContainer/VBoxContainer/PostGrid


func _ready():
	_spawn_dummy_thumbnails()


func _spawn_dummy_thumbnails():
	for i in 9:
		var thumb = preload("res://scenes/Spacegram/ProfileThumbnail.tscn").instantiate()
		post_grid.add_child(thumb)
