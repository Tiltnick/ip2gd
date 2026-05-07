extends Control

@onready var post_grid = $ScrollContainer/VBoxContainer/PostGrid

var all_posts = []

signal edit_profile_pressed
signal post_selected(posts, selected_index)



func _ready():
	_spawn_dummy_thumbnails()


func _spawn_dummy_thumbnails():
	for i in 9:
		var data = {
			"image": preload("res://wiki/Photo_Front.png"),
			"caption": "Post " + str(i)
		}

		all_posts.append(data)

		var thumb = preload("res://scenes/Spacegram/ProfileThumbnail.tscn").instantiate()
		post_grid.add_child(thumb)

		thumb.thumbnail_pressed.connect(func(_post_data):
			post_selected.emit(all_posts, i)
		)


func _on_edit_profile_button_pressed():
	edit_profile_pressed.emit()


	
