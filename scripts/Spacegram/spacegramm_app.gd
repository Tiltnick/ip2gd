extends Control

@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var profile_settings_view = $ContentContainer/ProfileSettingsView
@onready var comments_overlay = $CommentsOverlay
@onready var bottom_nav = $ColorRect2
@onready var post_detail_view = $ContentContainer/PostDetailView
@onready var post_new_post_view = $ContentContainer/PostNewPostView

signal open_camera_requested


func _ready():
	show_feed()
	feed_view.setup_dependencies(comments_overlay, bottom_nav)
	post_detail_view.comments_overlay = comments_overlay
	post_detail_view.bottom_nav = bottom_nav
	comments_overlay.bottom_nav = bottom_nav
	profile_view.edit_profile_pressed.connect(show_profile_settings)
	profile_settings_view.back_pressed.connect(show_profile)
	profile_view.post_selected.connect(show_post_detail)



func show_feed():
	feed_view.visible = true
	profile_view.visible = false
	profile_settings_view.visible = false
	post_detail_view.visible = false


func show_profile_settings():
	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = true


func show_profile():
	feed_view.visible = false
	profile_view.visible = true
	profile_settings_view.visible = false
	post_detail_view.visible = false
	
func show_post_detail(posts, selected_index):

	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = false

	post_detail_view.visible = true

	post_detail_view.setup(posts, selected_index)


	
func show_new_post_view():
	post_new_post_view.visible = true

func _on_profile_button_pressed():
	show_profile()


func _on_home_button_pressed():
	show_feed()
	
	
func _on_add_button_pressed():
	open_camera_requested.emit()
