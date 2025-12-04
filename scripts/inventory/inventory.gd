extends Control

@export var show_key_label := false

var slots: Array = []
var selected_slot := -1

func _ready():
	var display = find_child("Display", true, false)
	if display:
		slots = display.get_children()
	else:
		print("Inventory Display nicht gefunden!")
		return

	hotbarglobal.inventory = self

	for i in range(slots.size()):
		var slot = slots[i]

		if slot.has_method("set_slot_index"):
			slot.set_slot_index(i)

		if slot.has_method("set_click_callback"):
			slot.set_click_callback(_on_slot_clicked)

	update_slots()


func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()

	_update_selected_visuals()


func _on_slot_clicked(index: int):
	selected_slot = index
	_update_selected_visuals()

	var item_id = hotbarglobal.inventory_items[index]
	if not item_id:
		return

	if not ItemDatabase.DATA.has(item_id):
		print("Item nicht in Datenbank:", item_id)
		return

	var data = ItemDatabase.DATA[item_id]
	print("Item ID:", item_id)
	print("Aus Datenbank geladen:", data)


	$Description/Title.text = data.get("name", "Unknown")
	$Description/Text.text = data.get("description", "Keine Beschreibung")
	$Description/Slot17.set_item_icon(item_id)


func _update_selected_visuals():
	for i in range(slots.size()):
		var border = slots[i].get_node("Border")
		if border == null:
			continue

		if i == selected_slot:
			border.self_modulate = Color(1, 1, 1, 1)    # aktiv
		else:
			border.self_modulate = Color(0.6, 0.6, 0.6) # inaktiv
