extends Control

@onready var comments_vbox = $MarginContainerPanel/Panel/VBoxContainer/CommentsScroll/CommentsVBox
@onready var close_button = $MarginContainerPanel/Panel/VBoxContainer/MarginContainerHeader/Header/MarginContainerClose/CloseButton
@onready var text_edit = $MarginContainerPanel/Panel/VBoxContainer/InputRow/CodeEdit
@onready var post_button = $MarginContainerPanel/Panel/VBoxContainer/InputRow/MarginContainer/PostButton

const COMMENT_ITEM_SCENE := preload("res://scenes/Spacegram/CommentItem.tscn")

var bottom_nav
var current_post_id: String = ""
var current_post_item = null


func _ready():
	visible = false


func open_for_post(post_id: String, post_item = null) -> void:
	current_post_id = post_id
	current_post_item = post_item

	visible = true

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

	comment.setup(
		username,
		comment_text_value,
		time,
		0,
		false,
		comment_id,
		user_id
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

		await load_comments()
	else:
		print("Kommentar konnte nicht gelöscht werden: ", result.error)
