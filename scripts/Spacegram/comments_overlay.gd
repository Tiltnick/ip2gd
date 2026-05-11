extends Control

@onready var comments_vbox = $MarginContainerPanel/Panel/VBoxContainer/CommentsScroll/CommentsVBox
@onready var close_button = $MarginContainerPanel/Panel/VBoxContainer/MarginContainerHeader/Header/MarginContainerClose/CloseButton
@onready var text_edit = $MarginContainerPanel/Panel/VBoxContainer/InputRow/TextEdit

var bottom_nav

func _ready():
	visible = false
	
	
	_spawn_dummy_comments()
	
func _spawn_dummy_comments():
	for i in 5:
		var comment = preload("res://scenes/Spacegram/CommentItem.tscn").instantiate()
		
		comments_vbox.add_child(comment)
		comment.reply_requested.connect(_on_reply_requested)
		comment.setup(
			"User" + str(i),
			"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
			str(i) + "h",
			randi() % 2000
		)

func _on_close_pressed():
	visible = false
	bottom_nav.visible = true

func _on_reply_requested(username):

	text_edit.text = "@" + username + " "
	text_edit.grab_focus()

	text_edit.set_caret_column(text_edit.text.length())
