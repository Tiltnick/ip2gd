extends Control

@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var comments_overlay = $ContentContainer/CommentsOverlay
@onready var bottom_nav = $ColorRect2


func _ready():
	show_feed()
	feed_view.setup_dependencies(comments_overlay, bottom_nav)
	comments_overlay.bottom_nav = bottom_nav


func show_feed():
	feed_view.visible = true
	profile_view.visible = false


func show_profile():
	feed_view.visible = false
	profile_view.visible = true


func _on_profile_button_pressed():
	show_profile()


func _on_home_button_pressed():
	show_feed()
