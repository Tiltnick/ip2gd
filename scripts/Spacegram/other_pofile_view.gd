extends Control

@onready var post_grid = $ScrollContainer/VBoxContainer/PostGrid
@onready var username_label = $ScrollContainer/VBoxContainer/MarginContainer3/TopBar/Username
@onready var post_number_label = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/CenterStatsAndButton/StatsContainer/PostsStat/NumberLabel
@onready var friend_number_label = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/CenterStatsAndButton/StatsContainer/FriendStat/NumberLabel
@onready var bio_label = $ScrollContainer/VBoxContainer/MarginContainer2/BioLabel
@onready var profile_image = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/ProfileAndUsername/ProfileImageFrame/ProfileImage

@onready var follow_button = get_node_or_null("ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/CenterStatsAndButton/FollowButtonCenter/FollowButton")

const THUMBNAIL_SCENE := preload("res://scenes/Spacegram/ProfileThumbnail.tscn")
const FALLBACK_POST_IMAGE := preload("res://assets/sprites/portrait/selfie.png")

var all_posts: Array = []
var current_user_id: String = ""
var is_following := true
var follower_count := 0

signal post_selected(posts, selected_index)
signal follow_changed
signal back_requested

func load_profile_by_user_id(user_id: String) -> void:
	current_user_id = user_id

	_clear_thumbnails()
	await get_tree().process_frame
	all_posts.clear()

	if current_user_id.is_empty():
		print("OtherProfileView: Keine user_id gesetzt.")
		return

	var profile_result = await SpacegramApi.get_profile_by_user_id(current_user_id)

	if not profile_result.success or profile_result.data == null:
		print("OtherProfileView: Profil konnte nicht geladen werden: ", profile_result.error)
		return

	var profile_data: Dictionary = profile_result.data

	var display_name: String = str(profile_data.get("display_name", "Unknown"))
	var bio: String = str(profile_data.get("bio", ""))
	var profile_picture: String = str(profile_data.get("profile_picture", ""))

	follower_count = int(profile_data.get("follower_count", 0))
	is_following = bool(profile_data.get("followed_by_me", false))

	username_label.text = display_name
	bio_label.text = bio
	friend_number_label.text = str(follower_count)

	if not profile_picture.is_empty() and ResourceLoader.exists(profile_picture):
		profile_image.texture = load(profile_picture)

	_update_follow_button()

	var posts_result = await SpacegramApi.get_posts()

	if not posts_result.success:
		print("OtherProfileView: Posts konnten nicht geladen werden: ", posts_result.error)
		return

	var posts: Array = posts_result.data

	for post_data in posts:
		if str(post_data.get("user_id", "")) == current_user_id:
			all_posts.append(post_data)

	post_number_label.text = str(all_posts.size())

	for i in all_posts.size():
		_spawn_thumbnail(all_posts[i], i)


func _spawn_thumbnail(post_data: Dictionary, index: int) -> void:
	var thumb = THUMBNAIL_SCENE.instantiate()
	post_grid.add_child(thumb)

	var image_path: String = str(post_data.get("image_path", ""))
	var image_texture: Texture2D = _load_post_texture(image_path)

	thumb.setup(post_data, image_texture)

	thumb.thumbnail_pressed.connect(func(_post_data):
		post_selected.emit(all_posts, index)
	)


func _load_post_texture(image_path: String) -> Texture2D:
	if image_path.is_empty():
		return FALLBACK_POST_IMAGE

	if image_path.begins_with("user://"):
		var image := Image.new()
		var error := image.load(image_path)

		if error != OK:
			print("OtherProfileView: user:// Bild nicht gefunden: ", image_path)
			return FALLBACK_POST_IMAGE

		return ImageTexture.create_from_image(image)

	var normalized_path := image_path

	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path

	if not ResourceLoader.exists(normalized_path):
		print("OtherProfileView: Bild nicht gefunden: ", normalized_path)
		return FALLBACK_POST_IMAGE

	var texture = load(normalized_path)

	if texture is Texture2D:
		return texture

	return FALLBACK_POST_IMAGE


func _clear_thumbnails() -> void:
	for child in post_grid.get_children():
		child.queue_free()


func _update_follow_button() -> void:
	if follow_button == null:
		return

	if is_following:
		follow_button.text = "Following"
	else:
		follow_button.text = "Follow"


func _on_follow_button_pressed() -> void:
	if current_user_id.is_empty():
		return

	if NakamaManager.is_logged_in() and current_user_id == NakamaManager.session.user_id:
		return

	if follow_button:
		follow_button.disabled = true

	var result: Dictionary

	if is_following:
		result = await SpacegramApi.unfollow_user(current_user_id)
	else:
		result = await SpacegramApi.follow_user(current_user_id)

	if result.success:
		is_following = !is_following

		if is_following:
			follower_count += 1
		else:
			follower_count = max(follower_count - 1, 0)

		friend_number_label.text = str(follower_count)

		_update_follow_button()
		follow_changed.emit()
	else:
		print("OtherProfileView: Follow/Unfollow fehlgeschlagen: ", result.error)

	if follow_button:
		follow_button.disabled = false
		
		
func _on_back_button_pressed() -> void:
	back_requested.emit()
