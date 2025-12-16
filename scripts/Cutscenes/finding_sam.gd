extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.start_dialog("res://dialog/innerMonologue/discovering_sams_body.json")
	
