extends Control

@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var profile_settings_view = $ContentContainer/ProfileSettingsView
@onready var comments_overlay = $ContentContainer/CommentsOverlay
@onready var bottom_nav = $ColorRect2



func _ready():
	show_feed()
	feed_view.setup_dependencies(comments_overlay, bottom_nav)
	comments_overlay.bottom_nav = bottom_nav
	profile_view.edit_profile_pressed.connect(show_profile_settings)
	profile_settings_view.back_pressed.connect(show_profile)


func show_feed():
	feed_view.visible = true
	profile_view.visible = false


func show_profile_settings():
	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = true


func show_profile():
	feed_view.visible = false
	profile_view.visible = true
	profile_settings_view.visible = false

func _on_profile_button_pressed():
	show_profile()


func _on_home_button_pressed():
	show_feed()
	
