extends Control

@onready var posts_vbox = $ScrollContainer/VBoxContainer


func setup(posts, selected_index):
	
	# alte löschen
	for child in posts_vbox.get_children():
		child.queue_free()

	
	# neue posts spawnen
	for i in posts.size():
		var post = preload("res://scenes/Spacegram/PostItem.tscn").instantiate()

		posts_vbox.add_child(post)

		post.setup_post(
			posts[i]["image"],
			posts[i]["caption"]
		)

	
	await get_tree().process_frame

	
	# zum ausgewählten scrollen
	var target = posts_vbox.get_child(selected_index)

	$ScrollContainer.scroll_vertical = target.position.y
