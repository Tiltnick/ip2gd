extends PanelContainer

@onready var stories_row = $TopBar/ScrollContainer/StoriesRow
@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var top_bar = $TopBar

func show_profile():
	feed_view.visible = false
	profile_view.visible = true
	top_bar.visible = false

func _on_profile_button_pressed():
	show_profile()
