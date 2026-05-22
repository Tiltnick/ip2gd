extends Control

@onready var comments_vbox = $MarginContainerPanel/Panel/VBoxContainer/CommentsScroll/CommentsVBox
@onready var close_button = $MarginContainerPanel/Panel/VBoxContainer/MarginContainerHeader/Header/MarginContainerClose/CloseButton
@onready var text_edit = $MarginContainerPanel/Panel/VBoxContainer/InputRow/CodeEdit
@onready var post_button = $MarginContainerPanel/Panel/VBoxContainer/InputRow/MarginContainer/PostButton
@onready var input_profile_icon = $MarginContainerPanel/Panel/VBoxContainer/InputRow/FrameProfileIcon/ProfileIcon

const COMMENT_ITEM_SCENE := preload("res://scenes/Spacegram/CommentItem.tscn")

var bottom_nav
var current_post_id: String = ""
var current_post_item = null

signal comments_changed

func _ready():
	visible = false
	refresh_input_profile_icon()


func open_for_post(post_id: String, post_item = null) -> void:
	current_post_id = post_id
	current_post_item = post_item

	visible = true
	await refresh_input_profile_icon()

	if bottom_nav:
		bottom_nav.visible = false

	await load_comments()


func load_comments() -> void:
	_clear_comments()

	if current_post_id.is_empty():
		print("CommentsOverlay: Keine post_id gesetzt.")
		return

	var result = await SpacegramApi.get_comments(current_post_id)

	if not result.success:
		print("CommentsOverlay: Kommentare konnten nicht geladen werden: ", result.error)
		return

	var comments: Array = result.data

	for comment_data in comments:
		_spawn_comment(comment_data)


func _spawn_comment(comment_data: Dictionary) -> void:
	var comment = COMMENT_ITEM_SCENE.instantiate()
	comments_vbox.add_child(comment)

	comment.reply_requested.connect(_on_reply_requested)
	comment.delete_requested.connect(_on_delete_comment_requested)

	var username := str(comment_data.get("display_name", "Unknown"))
	var comment_text_value: String = str(comment_data.get("text", ""))
	var time := _format_comment_time(str(comment_data.get("posted_at", "")))
	var comment_id := str(comment_data.get("comment_id", ""))
	var user_id := str(comment_data.get("user_id", ""))
	var profile_picture := str(comment_data.get("profile_picture", ""))

	comment.setup(
		username,
		comment_text_value,
		time,
		0,
		false,
		comment_id,
		user_id,
		profile_picture
	)


func _clear_comments() -> void:
	for child in comments_vbox.get_children():
		child.queue_free()


func _on_close_pressed():
	visible = false

	if bottom_nav:
		bottom_nav.visible = true


func _on_post_button_pressed() -> void:
	var comment_text_input: String = text_edit.text.strip_edges()

	if comment_text_input.is_empty():
		return

	if current_post_id.is_empty():
		print("CommentsOverlay: Kein aktueller Post gesetzt.")
		return

	post_button.disabled = true

	var result = await SpacegramApi.create_comment(current_post_id, comment_text_input)

	if result.success:
		text_edit.text = ""

		if current_post_item:
			current_post_item.increment_comment_count()

		comments_changed.emit()

		await load_comments()
	else:
		print("Kommentar konnte nicht erstellt werden: ", result.error)

	post_button.disabled = false


func _on_reply_requested(username):
	var mention = "@" + username

	var highlighter = CodeHighlighter.new()
	highlighter.add_keyword_color(
		mention,
		Color("75d6bfff")
	)

	text_edit.syntax_highlighter = highlighter
	text_edit.text = mention + " "
	text_edit.grab_focus()
	text_edit.set_caret_column(text_edit.text.length())
	text_edit.queue_redraw()


func _format_comment_time(_posted_at: String) -> String:
	return "now"


func _on_delete_comment_requested(comment_id: String) -> void:
	if comment_id.is_empty():
		return

	var result = await SpacegramApi.delete_comment(comment_id)

	if result.success:
		if current_post_item:
			current_post_item.decrement_comment_count()

		comments_changed.emit()

		await load_comments()
	else:
		print("Kommentar konnte nicht gelöscht werden: ", result.error)
		
		
func refresh_input_profile_icon() -> void:
	if not NakamaManager.is_logged_in():
		return

	var result = await SpacegramApi.get_my_profile()

	if not result.success or result.data == null:
		print("CommentsOverlay: eigenes Profilbild konnte nicht geladen werden.")
		return

	var profile_data: Dictionary = result.data
	var profile_picture: String = str(profile_data.get("profile_picture", ""))

	if profile_picture.is_empty():
		return

	if not ResourceLoader.exists(profile_picture):
		print("CommentsOverlay: Profilbild nicht gefunden: ", profile_picture)
		return

	var texture: Texture2D = load(profile_picture)

	if input_profile_icon is TextureRect:
		input_profile_icon.texture = texture
	elif input_profile_icon is TextureButton:
		input_profile_icon.texture_normal = texture
	else:
		print("CommentsOverlay: Unerwarteter Icon-Typ: ", input_profile_icon.get_class())
