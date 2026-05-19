extends Control

@onready var stories_row = $VBoxContainer/TopBar/ScrollContainer/StoriesRow
@onready var posts_vbox = $VBoxContainer/ScrollContainer/PostsVBox

const STORY_ITEM_SCENE := preload("res://scenes/Spacegram/StoryItem.tscn")
const POST_ITEM_SCENE := preload("res://scenes/Spacegram/PostItem.tscn")
const FALLBACK_POST_IMAGE := preload("res://assets/sprites/portrait/selfie.png")

var comments_overlay
var bottom_nav
var has_loaded_posts := false

signal post_changed


func _ready():
	_spawn_dummy_stories()


func setup_dependencies(overlay, nav):
	comments_overlay = overlay
	bottom_nav = nav
	
	_load_posts()


func _spawn_dummy_stories():
	for child in stories_row.get_children():
		child.queue_free()

	for i in 8:
		var story = STORY_ITEM_SCENE.instantiate()
		stories_row.add_child(story)


func _load_posts() -> void:
	if has_loaded_posts:
		return

	if not NakamaManager.is_logged_in():
		print("FeedView: User ist noch nicht eingeloggt, Posts werden nicht geladen.")
		return

	has_loaded_posts = true

	_clear_posts()

	var result = await SpacegramApi.get_posts()

	if not result.success:
		print("FeedView: Posts konnten nicht geladen werden: ", result.error)
		return

	var posts: Array = result.data

	if posts.is_empty():
		print("FeedView: Keine Posts vorhanden.")
		return

	for post_data in posts:
		_spawn_post(post_data)


func _spawn_post(post_data: Dictionary) -> void:
	var post = POST_ITEM_SCENE.instantiate()
	posts_vbox.add_child(post)

	post.comments_overlay = comments_overlay
	post.bottom_nav = bottom_nav
	
	post.post_changed.connect(_on_post_changed)

	var image_path: String = str(post_data.get("image_path", ""))
	var image_texture := _load_post_texture(image_path)

	post.setup_post_data(
		post_data,
		image_texture,
		false
	)


func _load_post_texture(image_path: String) -> Texture2D:
	if image_path.is_empty():
		return FALLBACK_POST_IMAGE

	if image_path.begins_with("user://"):
		var image := Image.new()
		var error := image.load(image_path)

		if error != OK:
			print("FeedView: user:// Bild nicht gefunden: ", image_path)
			return FALLBACK_POST_IMAGE

		return ImageTexture.create_from_image(image)

	var normalized_path := image_path

	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path

	if not ResourceLoader.exists(normalized_path):
		print("FeedView: Bild nicht gefunden: ", normalized_path)
		return FALLBACK_POST_IMAGE

	var texture = load(normalized_path)

	if texture is Texture2D:
		return texture

	return FALLBACK_POST_IMAGE


func _clear_posts() -> void:
	for child in posts_vbox.get_children():
		child.queue_free()


func refresh_posts() -> void:
	has_loaded_posts = false
	_load_posts()
	
func _on_post_changed() -> void:
	post_changed.emit()
