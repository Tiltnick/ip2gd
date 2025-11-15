extends Node2D

func _ready() -> void:
	# Start the dialogue once the scene loads.
	$DialogManager.start_dialog("res://dialog/test.json")
