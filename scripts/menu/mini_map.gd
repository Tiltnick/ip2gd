extends CanvasLayer

@onready var mini_map: CanvasLayer = $"."


func _ready() -> void:
	pass

func open():
	if mini_map.visible:
		mini_map.hide()
		return
	else:
		mini_map.show()
		return
