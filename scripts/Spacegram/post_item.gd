extends PanelContainer

@onready var post_image = $MarginContainer/VBoxContainer/ImageContainer/PostImage
@onready var caption_label = $MarginContainer/VBoxContainer/CaptionLabel

@onready var like_button = $MarginContainer/VBoxContainer/ActionsRow/LikeBlock/LikeButton
@onready var comment_button = $MarginContainer/VBoxContainer/ActionsRow/CommentBox/CommentButton

@onready var add_friend_frame = $MarginContainer/VBoxContainer/Header/FrameAddFriend
@onready var add_friend_button = $MarginContainer/VBoxContainer/Header/FrameAddFriend/AddFriendIcon

@onready var trash_frame = $MarginContainer/VBoxContainer/Header/FrameTrashcan
@onready var trash_icon = $MarginContainer/VBoxContainer/Header/FrameTrashcan/TrashIcon

@onready var username_label = $MarginContainer/VBoxContainer/Header/UsernameLabel
@onready var like_count_label = $MarginContainer/VBoxContainer/ActionsRow/LikeBlock/LikeCount
@onready var comment_count_label = $MarginContainer/VBoxContainer/ActionsRow/CommentBox/CommentCount


var comments_overlay
var bottom_nav

var post_id: String = ""
var user_id: String = ""

var is_liked := false
var is_friend := false

var like_count := 0
var comment_count := 0

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")

var friend = preload("res://assets/sprites/ui/check.png")
var add_friend = preload("res://assets/sprites/ui/add-friend (1).png")

signal delete_requested(post_id)
signal post_changed

func setup_post_data(post_data: Dictionary, image: Texture2D, is_detail := false) -> void:
	post_id = str(post_data.get("post_id", ""))
	user_id = str(post_data.get("user_id", ""))

	var display_name := str(post_data.get("display_name", "Unknown"))
	var caption := str(post_data.get("caption", ""))

	like_count = int(post_data.get("like_count", 0))
	comment_count = int(post_data.get("comment_count", 0))
	is_liked = bool(post_data.get("liked_by_me", false))

	username_label.text = display_name
	caption_label.text = caption
	post_image.texture = image

	_update_like_ui()
	_update_comment_ui()

	var is_own_post := false

	if NakamaManager.is_logged_in():
		is_own_post = user_id == NakamaManager.session.user_id

	add_friend_frame.visible = not is_detail and not is_own_post
	trash_frame.visible = is_detail and is_own_post


func setup_post(image: Texture2D, caption: String, is_detail := false) -> void:
	post_image.texture = image
	caption_label.text = caption

	add_friend_frame.visible = not is_detail
	trash_frame.visible = is_detail


func _update_like_ui() -> void:
	like_button.texture_normal = heart_filled if is_liked else heart_empty
	like_count_label.text = str(like_count)


func _update_comment_ui() -> void:
	comment_count_label.text = str(comment_count)


func _on_like_pressed() -> void:
	if post_id.is_empty():
		print("PostItem: Keine post_id gesetzt.")
		return

	like_button.disabled = true

	var old_is_liked := is_liked
	var old_like_count := like_count

	if is_liked:
		is_liked = false
		like_count = max(like_count - 1, 0)
		_update_like_ui()

		var result = await SpacegramApi.unlike_post(post_id)

		if not result.success:
			is_liked = old_is_liked
			like_count = old_like_count
			_update_like_ui()
			print("Unlike fehlgeschlagen: ", result.error)

	else:
		is_liked = true
		like_count += 1
		_update_like_ui()

		var result = await SpacegramApi.like_post(post_id)

		if not result.success:
			is_liked = old_is_liked
			like_count = old_like_count
			_update_like_ui()
			print("Like fehlgeschlagen: ", result.error)

	like_button.disabled = false
	post_changed.emit()


func _on_comment_pressed() -> void:
	if comments_overlay == null:
		return

	if post_id.is_empty():
		print("PostItem: Keine post_id gesetzt.")
		return

	comments_overlay.open_for_post(post_id, self)


func _on_add_friend_pressed() -> void:
	is_friend = !is_friend
	add_friend_button.texture_normal = friend if is_friend else add_friend

func _on_delete_pressed() -> void:
	if post_id.is_empty():
		print("PostItem: Keine post_id gesetzt.")
		return

	delete_requested.emit(post_id)

func increment_comment_count() -> void:
	comment_count += 1
	_update_comment_ui()
	
func decrement_comment_count() -> void:
	comment_count = max(comment_count - 1, 0)
	_update_comment_ui()
