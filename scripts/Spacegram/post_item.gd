extends PanelContainer

@onready var post_image = $MarginContainer/VBoxContainer/ImageContainer/PostImage
@onready var caption_label = $MarginContainer/VBoxContainer/CaptionLabel
@onready var like_button = $MarginContainer/VBoxContainer/ActionsRow/LikeBlock/LikeButton
@onready var comment_button = $MarginContainer/VBoxContainer/ActionsRow/CommentBox/CommentButton
@onready var add_friend_frame = $MarginContainer/VBoxContainer/Header/FrameAddFriend
@onready var add_friend_button = $MarginContainer/VBoxContainer/Header/FrameAddFriend/AddFriendIcon
@onready var trash_frame = $MarginContainer/VBoxContainer/Header/FrameTrashcan
@onready var trash_icon = $MarginContainer/VBoxContainer/Header/FrameTrashcan/TrashIcon


var comments_overlay
var bottom_nav

var is_liked := false
var is_friend := false

var heart_empty = preload("res://assets/sprites/ui/heart (3) (1).png")
var heart_filled = preload("res://assets/sprites/ui/heart (1) (1).png")

var friend = preload("res://assets/sprites/ui/check.png")
var add_friend = preload("res://assets/sprites/ui/add-friend (1).png")

func setup_post(
	image: Texture2D,
	caption: String,
	is_detail := false
):

	post_image.texture = image
	caption_label.text = caption

	add_friend_frame.visible = not is_detail
	trash_frame.visible = is_detail
	
func _on_like_pressed():
	is_liked = !is_liked
	like_button.texture_normal = heart_filled if is_liked else heart_empty
	
func _on_comment_pressed():
	comments_overlay.visible = true
	bottom_nav.visible = false
	
func _on_add_friend_pressed():
	is_friend = !is_friend
	add_friend_button.texture_normal = add_friend if is_friend else friend
