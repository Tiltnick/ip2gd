extends Control

@onready var comment_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CommentText
@onready var username_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/UsernameLabel
@onready var time_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/TimeLabel
@onready var like_count = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeCount
@onready var like_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeButton
@onready var replies_vbox = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RepliesContainer/MarginContainer/RepliesBox
@onready var show_replies_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ActionsRow/ShowRepliesButton
@onready var answer_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ActionsRow/AnswerButton
@onready var delete_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/DeleteCommentButton
@onready var profile_icon = $MarginContainer/VBoxContainer/HBoxContainer/FrameProfileIcon/ProfileIcon

signal reply_requested(username, comment_id)
signal delete_requested(comment_id)
signal comment_like_changed

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")

var is_liked := false
var replies_visible := false

var comment_id: String = ""
var user_id: String = ""



func setup(
	username: String,
	text: String,
	time: String,
	likes: int,
	is_reply := false,
	new_comment_id := "",
	new_user_id := "",
	profile_picture := "",
	liked_by_me := false
) -> void:
	comment_id = str(new_comment_id)
	user_id = str(new_user_id)

	comment_text.clear()
	comment_text.text = text
	
	username_label.text = username
	time_label.text = time
	like_count.text = str(likes)
	is_liked = bool(liked_by_me)
	_update_like_ui()
	_set_profile_icon(str(profile_picture))

	if is_reply:
		answer_button.visible = false
		show_replies_button.visible = false
		replies_vbox.visible = false
	else:
		answer_button.visible = true
		show_replies_button.visible = false
		replies_vbox.visible = false
	
	var is_own_comment := false
	
	if NakamaManager.is_logged_in():
		is_own_comment = user_id == NakamaManager.session.user_id

	delete_button.visible = is_own_comment

func _on_like_pressed():
	if comment_id.is_empty():
		print("CommentItem: Keine comment_id gesetzt.")
		return

	like_button.disabled = true

	var old_is_liked := is_liked
	var old_like_count := int(like_count.text)

	if is_liked:
		is_liked = false
		like_count.text = str(max(old_like_count - 1, 0))
		_update_like_ui()

		var result = await SpacegramApi.unlike_comment(comment_id)

		if not result.success:
			is_liked = old_is_liked
			like_count.text = str(old_like_count)
			_update_like_ui()
			print("Unlike Comment fehlgeschlagen: ", result.error)
	else:
		is_liked = true
		like_count.text = str(old_like_count + 1)
		_update_like_ui()

		var result = await SpacegramApi.like_comment(comment_id)

		if not result.success:
			is_liked = old_is_liked
			like_count.text = str(old_like_count)
			_update_like_ui()
			print("Like Comment fehlgeschlagen: ", result.error)

	like_button.disabled = false
	comment_like_changed.emit()
		
func add_reply(username: String, text: String, time: String, likes: int):
	var reply = preload("res://scenes/Spacegram/CommentItem.tscn").instantiate()
	
	replies_vbox.add_child(reply)
	reply.setup(username, text, time, likes, true)
	
func _on_show_replies_pressed():
	replies_visible = !replies_visible
	replies_vbox.visible = replies_visible
	
	show_replies_button.text = tr("HIDE_REPLIES") if replies_visible else tr("SHOW_REPLIES")
	
func _on_answer_pressed():
	reply_requested.emit(username_label.text, comment_id)
	
	
func _on_delete_pressed() -> void:
	print("Delete Button gedrückt für comment_id: ", comment_id)

	if comment_id.is_empty():
		print("CommentItem: Keine comment_id gesetzt.")
		return

	delete_requested.emit(comment_id)


func _set_profile_icon(profile_picture: String) -> void:
	if profile_picture.is_empty():
		return

	if not ResourceLoader.exists(profile_picture):
		print("CommentItem: Profilbild nicht gefunden: ", profile_picture)
		return

	var texture: Texture2D = load(profile_picture)

	if profile_icon is TextureRect:
		profile_icon.texture = texture
	elif profile_icon is TextureButton:
		profile_icon.texture_normal = texture
	else:
		print("CommentItem: ProfileIcon hat unerwarteten Typ: ", profile_icon.get_class())
		
		
func add_reply_from_data(comment_data: Dictionary) -> void:
	var reply = preload("res://scenes/Spacegram/CommentItem.tscn").instantiate()
	replies_vbox.add_child(reply)

	var username := str(comment_data.get("display_name", "Unknown"))
	var text := str(comment_data.get("text", ""))
	var time := "now"
	var reply_comment_id := str(comment_data.get("comment_id", ""))
	var reply_user_id := str(comment_data.get("user_id", ""))
	var profile_picture := str(comment_data.get("profile_picture", ""))
	var like_count_value := int(comment_data.get("like_count", 0))
	var liked_by_me := bool(comment_data.get("liked_by_me", false))

	reply.setup(
		username,
		text,
		time,
		like_count_value,
		true,
		reply_comment_id,
		reply_user_id,
		profile_picture,
		liked_by_me
	)

	reply.delete_requested.connect(func(id):
		delete_requested.emit(id)
	)
	
	reply.comment_like_changed.connect(func():
		comment_like_changed.emit()
	)

	show_replies_button.visible = true

func set_replies_visible(value: bool) -> void:
	replies_visible = value
	replies_vbox.visible = value
	
	if show_replies_button.visible:
		show_replies_button.text = tr("HIDE_REPLIES") if value else tr("SHOW_REPLIES")
		
		
func _update_like_ui() -> void:
	like_button.texture_normal = heart_filled if is_liked else heart_empty
