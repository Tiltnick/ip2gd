extends Control

@onready var post_grid = $ScrollContainer/VBoxContainer/PostGrid
@onready var username_label = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/ProfileAndUsername/Username
@onready var number_label = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/CenterStatsAndButton/StatsContainer/PostsStat/NumberLabel
@onready var bio_label = $ScrollContainer/VBoxContainer/MarginContainer2/BioLabel
@onready var profile_image = $ScrollContainer/VBoxContainer/MarginContainer/ProfileHeader/ProfileAndUsername/ProfileImageFrame/ProfileImage


const THUMBNAIL_SCENE := preload("res://scenes/Spacegram/ProfileThumbnail.tscn")
const FALLBACK_POST_IMAGE := preload("res://assets/sprites/portrait/selfie.png")

var all_posts: Array = []

signal edit_profile_pressed
signal post_selected(posts, selected_index)


func _ready():
	pass


func load_profile() -> void:
	_clear_thumbnails()
	await get_tree().process_frame
	
	all_posts.clear()

	if not NakamaManager.is_logged_in():
		print("ProfileView: Nicht eingeloggt.")
		return

	var profile_result = await SpacegramApi.get_my_profile()

	if profile_result.success and profile_result.data != null:
		var profile_data: Dictionary = profile_result.data

		var display_name: String = str(profile_data.get("display_name", NakamaManager.session.username))
		var bio: String = str(profile_data.get("bio", ""))
		var profile_picture: String = str(profile_data.get("profile_picture", ""))

		username_label.text = display_name
		bio_label.text = bio

		if not profile_picture.is_empty() and ResourceLoader.exists(profile_picture):
			profile_image.texture = load(profile_picture)
	else:
		username_label.text = str(NakamaManager.session.username)
		bio_label.text = ""

	var posts_result = await SpacegramApi.get_posts()

	if not posts_result.success:
		print("ProfileView: Posts konnten nicht geladen werden: ", posts_result.error)
		return

	var posts: Array = posts_result.data
	var current_user_id: String = str(NakamaManager.session.user_id)

	for post_data in posts:
		if str(post_data.get("user_id", "")) == current_user_id:
			all_posts.append(post_data)

	number_label.text = str(all_posts.size())

	for i in all_posts.size():
		_spawn_thumbnail(all_posts[i], i)


func _spawn_thumbnail(post_data: Dictionary, index: int) -> void:
	var thumb = THUMBNAIL_SCENE.instantiate()
	post_grid.add_child(thumb)

	var image_path: String = str(post_data.get("image_path", ""))
	var image_texture := _load_post_texture(image_path)

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
			print("ProfileView: user:// Bild nicht gefunden: ", image_path)
			return FALLBACK_POST_IMAGE

		return ImageTexture.create_from_image(image)

	var normalized_path := image_path

	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path

	if not ResourceLoader.exists(normalized_path):
		print("ProfileView: Bild nicht gefunden: ", normalized_path)
		return FALLBACK_POST_IMAGE

	var texture = load(normalized_path)

	if texture is Texture2D:
		return texture

	return FALLBACK_POST_IMAGE


func _clear_thumbnails() -> void:
	for child in post_grid.get_children():
		child.queue_free()


func refresh_profile() -> void:
	await load_profile()


func _on_edit_profile_button_pressed():
	edit_profile_pressed.emit()
