extends Control
class_name HotbarSlot

@onready var icon := $Icon
@onready var key_label := $"Label for Keys"
@onready var count_label := get_node_or_null("CountLabel") 

@export var show_key_label: bool = true

var slot_index := -1
var click_callback: Callable = Callable()

const SLOT_ICON_SIZE = Vector2(64, 64)

func _ready():
	# counter standardmäßig aus
	if count_label:
		count_label.visible = false
	_apply_key_label_visibility()


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if click_callback:
			click_callback.call(slot_index)


# Wird von hotbar und inventory gesetzt
func set_click_callback(func_ref):
	click_callback = func_ref


func set_item_icon(item_id: String):
	if not icon or item_id == null:
		clear_icon()
		return
		
	# hotbar override für die stone pieces
	if hotbarglobal and hotbarglobal.has_method("get_hotbar_display_item_id"):
		item_id = hotbarglobal.get_hotbar_display_item_id(item_id)


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

	# Wenn Icon weg ist counter auch weg
	set_stack_count(0)


# Counter setzen, sihctbar nur bei mehr als 1 item
func set_stack_count(count: int) -> void:
	if not count_label:
		return

	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false


func set_slot_index(i: int):
	slot_index = i

	if not key_label:
		return

	key_label.text = str(i + 1)
	key_label.visible = show_key_label



			
			
func _apply_key_label_visibility() -> void:
	if not key_label:
		return

	key_label.visible = show_key_label
