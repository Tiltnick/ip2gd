extends Control

@onready var feed_view = $ContentContainer/FeedView
@onready var profile_view = $ContentContainer/ProfileView
@onready var profile_settings_view = $ContentContainer/ProfileSettingsView
@onready var comments_overlay = $CommentsOverlay
@onready var bottom_nav = $ColorRect2
@onready var post_detail_view = $ContentContainer/PostDetailView
@onready var post_new_post_view = $ContentContainer/PostNewPostView
@onready var confirm_popup = $SpacegramConfirmPopup

#@onready var bottom_nav_profile_button = $ColorRect2/MarginContainer/BottomNavBar/PanelContainerProfile/Profile
@onready var bottom_nav_profile_button = get_node_or_null("ColorRect2/MarginContainer/BottomNavBar/PanelContainerProfile/Profile")

var feed_is_dirty := false
var profile_is_dirty := false

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
	post_new_post_view.post_created.connect(_on_post_created)
	post_new_post_view.cancel_requested.connect(show_feed)
	post_detail_view.post_deleted.connect(_on_post_deleted)
	post_detail_view.confirm_popup = confirm_popup
	feed_view.post_changed.connect(_on_spacegram_data_changed)
	post_detail_view.post_changed.connect(_on_spacegram_data_changed)
	comments_overlay.comments_changed.connect(_on_spacegram_data_changed)
	profile_settings_view.profile_saved.connect(_on_profile_saved)
	post_new_post_view.change_picture_requested.connect(_on_change_picture_requested)
	
	
	print("BottomNav button found: ", bottom_nav_profile_button)

	if bottom_nav_profile_button:
		print("BottomNav button class: ", bottom_nav_profile_button.get_class())
	refresh_bottom_nav_avatar()


func show_feed():
	feed_view.visible = true
	profile_view.visible = false
	profile_settings_view.visible = false
	post_detail_view.visible = false
	post_new_post_view.visible = false
	
	if feed_is_dirty:
		feed_is_dirty = false
		feed_view.refresh_posts()


func show_profile_settings():
	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = true
	post_detail_view.visible = false
	post_new_post_view.visible = false
	
	await profile_settings_view.load_settings()


func show_profile():
	feed_view.visible = false
	profile_view.visible = true
	profile_settings_view.visible = false
	post_detail_view.visible = false
	post_new_post_view.visible = false
	
	profile_is_dirty = false
	await profile_view.refresh_profile()
	
func show_post_detail(posts, selected_index):

	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = false
	post_new_post_view.visible = false

	post_detail_view.visible = true

	post_detail_view.setup(posts, selected_index)


	
func show_new_post_view(image_path: String):

	feed_view.visible = false
	profile_view.visible = false
	profile_settings_view.visible = false
	post_detail_view.visible = false
	comments_overlay.visible = false

	post_new_post_view.visible = true
	post_new_post_view.setup(image_path)

func _on_profile_button_pressed():
	show_profile()


func _on_home_button_pressed():
	show_feed()
	
func _on_post_deleted() -> void:
	feed_view.refresh_posts()
	await profile_view.refresh_profile()
	show_profile()
	
	
func _on_add_button_pressed():
	open_camera_requested.emit()
	
func _on_post_created() -> void:
	show_feed()
	feed_view.refresh_posts()
	profile_view.refresh_profile()
	
func _on_spacegram_data_changed() -> void:
	feed_is_dirty = true
	profile_is_dirty = true
	if feed_view.visible:
		feed_view.load_stories()
	
func _on_profile_saved() -> void:
	feed_is_dirty = true
	profile_is_dirty = true
	await refresh_bottom_nav_avatar()
	await show_profile()
	
func _on_change_picture_requested() -> void:
	post_new_post_view.visible = false
	open_camera_requested.emit()
	
func refresh_bottom_nav_avatar() -> void:
	if bottom_nav_profile_button == null:
		print("BottomNav: Profile Button wurde nicht gefunden.")
		return

	if not NakamaManager.is_logged_in():
		return

	var result = await SpacegramApi.get_my_profile()

	if not result.success or result.data == null:
		print("BottomNav: Profil konnte nicht geladen werden.")
		return

	var profile_data: Dictionary = result.data
	var profile_picture: String = str(profile_data.get("profile_picture", ""))

	if profile_picture.is_empty():
		return

	if not ResourceLoader.exists(profile_picture):
		print("BottomNav: Profilbild nicht gefunden: ", profile_picture)
		return

	var texture: Texture2D = load(profile_picture)

	if bottom_nav_profile_button is TextureButton:
		bottom_nav_profile_button.texture_normal = texture
	elif bottom_nav_profile_button is TextureRect:
		bottom_nav_profile_button.texture = texture
	else:
		print("BottomNav: Unerwarteter Node-Typ: ", bottom_nav_profile_button.get_class())
