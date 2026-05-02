extends PanelContainer

@onready var post_image = $MarginContainer/VBoxContainer/ImageContainer/PostImage
@onready var caption_label = $MarginContainer/VBoxContainer/CaptionLabel
@onready var like_button = $MarginContainer/VBoxContainer/ActionsRow/LikeButton
@onready var comment_button = $MarginContainer/VBoxContainer/ActionsRow/CommentButton

var comments_overlay
var bottom_nav

var is_liked := false

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")


func setup_post(image: Texture2D, caption: String):
	post_image.texture = image
	caption_label.text = caption
	
func _on_like_pressed():
	is_liked = !is_liked
	like_button.texture_normal = heart_filled if is_liked else heart_empty
	
func _on_comment_pressed():
	comments_overlay.visible = true
	bottom_nav.visible = false
