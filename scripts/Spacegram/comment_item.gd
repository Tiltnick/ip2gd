extends Control

@onready var comment_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CommentText
@onready var username_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/UsernameLabel
@onready var time_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/TimeLabel
@onready var like_count = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeCount
@onready var like_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeButton
@onready var replies_vbox = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/RepliesContainer/MarginContainer/RepliesBox
@onready var show_replies_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ActionsRow/ShowRepliesButton
@onready var answer_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ActionsRow/AnswerButton

signal reply_requested(username)

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")

var is_liked := false
var replies_visible := false

func _ready() -> void:
	like_button.pressed.connect(_on_like_pressed)

func setup(username: String, text: String, time: String, likes: int, is_reply := false) -> void:
	comment_text.clear()
	comment_text.text = text
	
	username_label.text = username
	time_label.text = time
	like_count.text = str(likes)
	replies_vbox.visible = false
	
	if not is_reply:
		add_reply("Truffle", "@Porccini Lorem ipsum!", "12h", 28)
		add_reply("AnotherUser", "Antwort hier", "2h", 5)
		
	show_replies_button.visible = replies_vbox.get_child_count() > 0

func _on_like_pressed():
	is_liked = !is_liked
	like_button.texture_normal = heart_filled if is_liked else heart_empty
		
func add_reply(username: String, text: String, time: String, likes: int):
	var reply = preload("res://scenes/Spacegram/CommentItem.tscn").instantiate()
	
	replies_vbox.add_child(reply)
	reply.setup(username, text, time, likes, true)
	
func _on_show_replies_pressed():
	replies_visible = !replies_visible
	replies_vbox.visible = replies_visible
	
	show_replies_button.text = tr("HIDE_REPLIES") if replies_visible else tr("SHOW_REPLIES")
	
func _on_answer_pressed():
	reply_requested.emit(username_label.text)
