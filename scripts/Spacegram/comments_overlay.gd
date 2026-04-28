extends Control

@onready var comments_vbox = $MarginContainerPanel/Panel/VBoxContainer/CommentsScroll/CommentsVBox

func _ready():
	_spawn_dummy_comments()
	
func _spawn_dummy_comments():
	for i in 5:
		var comment = preload("res://scenes/Spacegram/CommentItem.tscn").instantiate()
		comments_vbox.add_child(comment)
