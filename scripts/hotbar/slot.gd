extends Control
class_name HotbarSlot

@onready var icon := $Icon

# Maximalgröße des Icons im Slot
const SLOT_ICON_SIZE = Vector2(64, 64)

func set_item_icon(item_id: String):
	if not icon:
		return
	
	var path = ""
	if item_id == "diary":
		path = "res://assets/sprites/selfmade/waldgeist-32x (8).png"
	elif item_id == "photo":
		path = "res://assets/sprites/photos/Photo_Front.jpg"

	if ResourceLoader.exists(path):
		icon.texture = load(path)
		icon.size = SLOT_ICON_SIZE                     # Größe setzen
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = (size - SLOT_ICON_SIZE) / 2   # Mittig im Slot
	else:
		clear_icon()

func clear_icon():
	if icon:
		icon.texture = null
