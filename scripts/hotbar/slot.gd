extends Control
class_name HotbarSlot

@onready var icon := $Icon
@export var show_shadow: bool = true

var slot_index := -1
signal pressed(slot_index)

# Maximalgröße des Icons im Slot
const SLOT_ICON_SIZE = Vector2(64, 64)

func _ready():
	if not show_shadow:
		_disable_shadow()
		
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pressed", slot_index)



		
func set_item_icon(item_id: String):
	if not icon or item_id == null:
		clear_icon()
		return

	if not ItemDatabase.DATA.has(item_id):
		clear_icon()
		return

	var data = ItemDatabase.DATA[item_id]

	var path = data.icon
	var icon_size = data.get("icon_size", SLOT_ICON_SIZE)

	if ResourceLoader.exists(path):
		icon.texture = load(path)
		icon.size = icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = (size - icon_size) / 2
	else:
		clear_icon()



func clear_icon():
	if icon:
		icon.texture = null


func _disable_shadow():
	var stylebox: StyleBox = $Background.get("theme_override_styles/panel")
	if stylebox is StyleBoxFlat:
		var new_style: StyleBoxFlat = stylebox.duplicate()
		new_style.shadow_size = 0
		new_style.shadow_color = Color(0,0,0,0)
		$Background.set("theme_override_styles/panel", new_style)
