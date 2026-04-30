extends Control

@onready var comment_text = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CommentText
@onready var username_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/UsernameLabel
@onready var time_label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/TopRow/TimeLabel
@onready var like_count = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeCount
@onready var like_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LikeBlock/LikeButton

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")

var is_liked := false

func _ready() -> void:
	like_button.pressed.connect(_on_like_pressed)

func setup(username: String, text: String, time: String, likes: int) -> void:
	comment_text.clear()
	comment_text.text = text
	
	username_label.text = username
	time_label.text = time
	like_count.text = str(likes)

func _on_like_pressed():
	is_liked = !is_liked
	like_button.texture_normal = heart_filled if is_liked else heart_empty
		
