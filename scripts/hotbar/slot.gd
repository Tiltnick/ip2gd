extends Control
class_name HotbarSlot

@export var slot_index: int = 0

@onready var icon := $Icon
@onready var key_label := $"Label for Keys"

func _ready():
	key_label.text = str(slot_index + 1)
	icon.texture = null 
