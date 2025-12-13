extends Node
class_name Hotbarglobal

var hotbar_items = [null, null, null, null]

var inventory_items = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]

var hotbar_counts: Dictionary = {}

var hotbar: Control
var inventory: Control

func add_item(item_id: String) -> bool:
	if item_id == "":
		return false

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

func add_piece(piece_id: String, hotbar_type_id: String) -> void:
	if piece_id == "" or hotbar_type_id == "":
		return

	if not inventory_items.has(piece_id):
		for i in range(inventory_items.size()):
			if inventory_items[i] == null:
				inventory_items[i] = piece_id
				break

	if not hotbar_items.has(hotbar_type_id):
		for i in range(hotbar_items.size()):
			if hotbar_items[i] == null:
				hotbar_items[i] = hotbar_type_id
				break

	hotbar_counts[hotbar_type_id] = hotbar_counts.get(hotbar_type_id, 0) + 1

	update_ui()

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

func has_item(item_id: String) -> bool:
	return inventory_items.has(item_id) or hotbar_items.has(item_id)
