extends Control

@onready var stories_row = $TopBar/ScrollContainer/StoriesRow
@onready var posts_vbox = $ContentContainer/FeedView/ScrollContainer/PostsVBox
@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var top_bar = $TopBar

func _ready():
	show_feed()
	
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
		
		
func show_feed():
	feed_view.visible = true
	profile_view.visible = false
	top_bar.visible = true


func show_profile():
	feed_view.visible = false
	profile_view.visible = true
	top_bar.visible = false

func _on_profile_button_pressed():
	show_profile()
	
func _on_home_button_pressed():
	show_feed()
