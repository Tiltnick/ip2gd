extends Control

@onready var stories_row = $VBoxContainer/TopBar/ScrollContainer/StoriesRow
@onready var posts_vbox = $VBoxContainer/ScrollContainer/PostsVBox

var comments_overlay
var bottom_nav


func _ready():
	_spawn_dummy_stories()


func _spawn_dummy_stories():
	for i in 8:
		var story = preload("res://scenes/Spacegram/StoryItem.tscn").instantiate()
		stories_row.add_child(story)


func _spawn_dummy_posts():
	for i in 5:

		var post = preload("res://scenes/Spacegram/PostItem.tscn").instantiate()

		posts_vbox.add_child(post)

		post.comments_overlay = comments_overlay
		post.bottom_nav = bottom_nav

		post.setup_post(
			preload("res://wiki/Photo_Front.png"),
			"Post " + str(i),
			false
		)

func setup_dependencies(overlay, nav):
	comments_overlay = overlay
	bottom_nav = nav
	
	_spawn_dummy_posts()
