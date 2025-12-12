extends Node
class_name Hotbarglobal

var hotbar_items = [null, null, null, null]

var inventory_items = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]

var hotbar: Control
var inventory: Control

func add_item(item_id: String) -> bool:
	if item_id == "":
		return false

	# keine duplicates
	if hotbar_items.has(item_id) or inventory_items.has(item_id):
		update_ui()
		return true

	var hotbar_added := false
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == null:
			hotbar_items[i] = item_id
			hotbar_added = true
			break

	var inv_added := false
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item_id
			inv_added = true
			break

	update_ui()
	return hotbar_added or inv_added


func update_ui():
	if hotbar:
		hotbar.update_slots()

	if inventory:
		inventory.update_slots()
		if inventory.is_visible_in_tree():
			inventory._select_first_item()


func get_item_from_hotbar(slot: int) -> String:
	return hotbar_items[slot] if slot < hotbar_items.size() else null

func get_inventory_item(slot: int) -> String:
	return inventory_items[slot] if slot < inventory_items.size() else null

func get_hotbar_index_of_item(item_id: String) -> int:
	return hotbar_items.find(item_id)
