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
	# _select_first_item() NICHT mehr hier aufrufen – das macht jetzt update_slots()



func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()

	_update_selected_visuals()

	if selected_slot == -1:
		_select_first_item()



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

	# Titel & Beschreibung setzen
	$Description/Title.text = data.get("name", "Unknown")
	$Description/Text.text = data.get("description", "Keine Beschreibung")

	# Icon setzen
	$Description/Slot17.set_item_icon(item_id)

	# Hotbar-Key anzeigen (1–4), falls Item in Hotbar ist
	var hotbar_index = hotbarglobal.hotbar_items.find(item_id)

	if hotbar_index != -1:
		$Description/Slot17/"Label for Keys".text = str(hotbar_index + 1)
	else:
		$Description/Slot17/"Label for Keys".text = ""



func _update_selected_visuals():
	for i in range(slots.size()):
		var border = slots[i].get_node("Border")
		if border == null:
			continue

		if i == selected_slot:
			border.self_modulate = Color(1, 1, 1, 1)    # aktiv
		else:
			border.self_modulate = Color(0.6, 0.6, 0.6) # inaktiv



func _select_first_item():
	for i in range(hotbarglobal.inventory_items.size()):
		if hotbarglobal.inventory_items[i] != null:
			_on_slot_clicked(i)  # setzt selected_slot & UI selbst
			return
