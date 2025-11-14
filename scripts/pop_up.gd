extends Control
@onready var color_rect: ColorRect = $ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func open() -> void:
	color_rect.show()
	
func close() -> void:
	color_rect.hide()
