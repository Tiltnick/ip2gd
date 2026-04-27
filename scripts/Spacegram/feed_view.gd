extends Control

@onready var stories_row = $VBoxContainer/TopBar/ScrollContainer/StoriesRow
@onready var posts_vbox = $VBoxContainer/ScrollContainer/PostsVBox


func _ready():
	_spawn_dummy_stories()
	_spawn_dummy_posts()


func _spawn_dummy_stories():
	for i in 8:
		var story = preload("res://scenes/Spacegram/StoryItem.tscn").instantiate()
		stories_row.add_child(story)


func _spawn_dummy_posts():
	for i in 5:
		var post = preload("res://scenes/Spacegram/PostItem.tscn").instantiate()
		
		posts_vbox.add_child(post)
