extends Node
class_name Hotbarglobal

# 4 Hotbar-Slots
var hotbar_items = [null, null, null, null]

# 16 Inventory-Slots (4x4)
var inventory_items = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]

var hotbar: Control
var inventory: Control


# gleichzeitig
func add_item(item_id: String) -> void:
	# Hotbar füllen
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == null:
			hotbar_items[i] = item_id
			break

	# Inventory füllen
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item_id
			break

	update_ui()



func update_ui():
	if hotbar:
		hotbar.update_slots()

	if inventory:
		inventory.update_slots()


func get_item_from_hotbar(slot: int) -> String:
	return hotbar_items[slot] if slot < hotbar_items.size() else null


func get_inventory_item(slot: int) -> String:
	return inventory_items[slot] if slot < inventory_items.size() else null

func get_hotbar_index_of_item(item_id: String) -> int:
	return hotbar_items.find(item_id)
