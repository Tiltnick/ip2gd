extends Control

@onready var posts_vbox = $ScrollContainer/PostsBox

const POST_ITEM_SCENE := preload("res://scenes/Spacegram/PostItem.tscn")
const FALLBACK_POST_IMAGE := preload("res://assets/sprites/portrait/selfie.png")

var comments_overlay
var bottom_nav
var current_posts: Array = []
var confirm_popup

signal post_deleted
signal post_changed
signal back_requested

func setup(posts, selected_index):
	current_posts = posts

	for child in posts_vbox.get_children():
		child.queue_free()

	for i in posts.size():
		var post = POST_ITEM_SCENE.instantiate()
		posts_vbox.add_child(post)

		post.comments_overlay = comments_overlay
		post.bottom_nav = bottom_nav
		post.delete_requested.connect(_on_delete_post_requested)
		post.post_changed.connect(_on_post_changed)

		var image_path: String = str(posts[i].get("image_path", ""))
		var image_texture := _load_post_texture(image_path)

		post.setup_post_data(
			posts[i],
			image_texture,
			true
		)

	await get_tree().process_frame

	if selected_index < posts_vbox.get_child_count():
		var target = posts_vbox.get_child(selected_index)
		$ScrollContainer.scroll_vertical = target.position.y


func _on_delete_post_requested(post_id: String) -> void:
	var message := "Beitrag löschen?"

	var lang = TranslationServer.get_locale().substr(0, 2)

	if lang == "en":
		message = "Delete post?"

	if confirm_popup:
		var confirmed: bool = await confirm_popup.ask(message)
		
		if not confirmed:
			return

	await _delete_post_confirmed(post_id)


func _delete_post_confirmed(post_id: String) -> void:
	var result = await SpacegramApi.delete_post(post_id)

	if result.success:
		print("Post gelöscht: ", post_id)

		current_posts = current_posts.filter(
			func(post_data):
				return str(post_data.get("post_id", "")) != post_id
		)

		post_deleted.emit()

		if current_posts.is_empty():
			visible = false
			return

		setup(current_posts, 0)
	else:
		print("Post konnte nicht gelöscht werden: ", result.error)

func _load_post_texture(image_path: String) -> Texture2D:
	if image_path.is_empty():
		return FALLBACK_POST_IMAGE

	if image_path.begins_with("user://"):
		var image := Image.new()
		var error := image.load(image_path)

		if error != OK:
			return FALLBACK_POST_IMAGE

		return ImageTexture.create_from_image(image)

	var normalized_path := image_path

	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path

	if not ResourceLoader.exists(normalized_path):
		return FALLBACK_POST_IMAGE

	var texture = load(normalized_path)

	if texture is Texture2D:
		return texture

	return FALLBACK_POST_IMAGE
	
func _on_post_changed() -> void:
	post_changed.emit()
	
func _on_back_button_pressed() -> void:
	back_requested.emit()
