extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_popup():
	var popup = load("res://scenes/Spaceship_riddle/spaceship_door_riddle.tscn").instantiate()
	$CanvasLayer.add_child(popup)
	popup.global_position = get_viewport().get_visible_rect().size / 2 - popup.size / 2
