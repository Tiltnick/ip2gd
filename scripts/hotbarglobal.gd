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
var hotbar_icon_override: Dictionary = {}

var hotbar: Control
var inventory: Control

func add_item(item_id: String) -> bool:
	if item_id == "":
		return false

	if hotbar_items.has(item_id) or inventory_items.has(item_id):
		update_ui()
		return true

	# (dein restlicher add_item code bleibt wie bei dir)
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == null:
			hotbar_items[i] = item_id
			update_ui()
			return true

	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item_id
			update_ui()
			return true

	update_ui()
	return false


func update_ui():
	if hotbar:
		hotbar.update_slots()

	if inventory:
		inventory.update_slots()
		if inventory.is_visible_in_tree():
			inventory._select_first_item()


func remove_item(item_id: String) -> void:
	var removed := false

	# remove from inventory
	for i in range(inventory_items.size()):
		if inventory_items[i] == item_id:
			inventory_items[i] = null
			removed = true
			break

	# remove from hotbar
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == item_id:
			hotbar_items[i] = null
			removed = true
			break

	if removed:
		update_ui()


func get_item_from_hotbar(slot: int) -> String:
	return hotbar_items[slot] if slot < hotbar_items.size() else null

func get_inventory_item(slot: int) -> String:
	return inventory_items[slot] if slot < inventory_items.size() else null

func get_hotbar_index_of_item(item_id: String) -> int:
	return hotbar_items.find(item_id)

func has_item(item_id: String) -> bool:
	return inventory_items.has(item_id) or hotbar_items.has(item_id)
