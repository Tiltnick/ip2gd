extends Control
class_name HotbarSlot

@onready var icon := $Icon
@onready var key_label := $"Label for Keys"
@onready var count_label := get_node_or_null("CountLabel") # NEU

@export var show_shadow: bool = true
@export var show_key_label := true

var slot_index := -1
var click_callback: Callable = Callable()

const SLOT_ICON_SIZE = Vector2(64, 64)

func _ready():
	if not show_shadow:
		_disable_shadow()

	# Counter standardmäßig aus
	if count_label:
		count_label.visible = false


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Slot", slot_index, "wurrde angeklickt")
		if click_callback:
			click_callback.call(slot_index)


# Wird von hotbar u. inventory gesetzt
func set_click_callback(func_ref):
	click_callback = func_ref


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
		
		#icon.set_anchors_preset(Control.PRESET_TOP_LEFT)
		#icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		#icon.custom_minimum_size = icon_size
		
		icon.size = icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = (size - icon_size) / 2
	else:
		clear_icon()

#func _notification(what):
	#if what == NOTIFICATION_RESIZED:
		#if icon and icon.texture:
			#icon.position = (size - icon.size) / 2



func clear_icon():
	if icon:
		icon.texture = null

	# Wenn Icon weg ist, Counter auch weg
	set_stack_count(0)


# Counter setzen (sichtbar nur bei > 1)
func set_stack_count(count: int) -> void:
	if not count_label:
		return

	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false


func _disable_shadow():
	var stylebox: StyleBox = $Background.get("theme_override_styles/panel")
	if stylebox is StyleBoxFlat:
		var new_style: StyleBoxFlat = stylebox.duplicate()
		new_style.shadow_size = 0
		new_style.shadow_color = Color(0,0,0,0)
		$Background.set("theme_override_styles/panel", new_style)


func set_slot_index(i: int):
	slot_index = i

	if show_key_label and key_label:
		key_label.text = str(i + 1)
	else:
		if key_label:
			key_label.visible = false
