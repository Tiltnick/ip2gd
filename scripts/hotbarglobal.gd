extends Node
class_name Hotbarglobal

var inventory_items = [
	null, null, null, null,
	null, null, null, null,
	null, null, null, null,
	null, null, null, null
]

var hotbar_counts: Dictionary = {}
var hotbar_icon_override: Dictionary = {}

# Reihenfolge der Stack-Oberbegriffe in der Hotbar
var hotbar_stack_order: Array[String] = ["mushrooms", "stonepanel"]

var hotbar: Control
var inventory: Control


func _show_in_hotbar(item_id: String) -> bool:
	if item_id == "":
		return false
	if not ItemDatabase.DATA.has(item_id):
		return true
	var data: Dictionary = ItemDatabase.DATA[item_id]
	return bool(data.get("show_in_hotbar", true))


func _get_stack_group(item_id: String) -> String:
	if item_id == "":
		return ""
	if not ItemDatabase.DATA.has(item_id):
		return ""
	var data: Dictionary = ItemDatabase.DATA[item_id]
	return String(data.get("stack_group", ""))


func add_item(item_id: String) -> bool:
	if item_id == "":
		return false

	# so items aren't saved twice
	if inventory_items.has(item_id):
		print("has id in add item")
		update_ui()
		return true

	# add item to inventory
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item_id
			update_ui()
			return true

	return false


func add_piece(piece_id: String, hotbar_type_id: String) -> void:
	if piece_id == "" or hotbar_type_id == "":
		return

	# piece ins inventory
	if not inventory_items.has(piece_id):
		for i in range(inventory_items.size()):
			if inventory_items[i] == null:
				inventory_items[i] = piece_id
				break

	# Oberbegriff NICHT ins inventory (nur Hotbar!)
	hotbar_counts[hotbar_type_id] = int(hotbar_counts.get(hotbar_type_id, 0)) + 1
	hotbar_icon_override[hotbar_type_id] = piece_id

	update_ui()


func get_hotbar_display_item_id(item_id: String) -> String:
	return hotbar_icon_override.get(item_id, item_id)


func update_ui():
	if hotbar:
		hotbar.update_slots()

	if inventory:
		inventory.update_slots()
		if inventory.is_visible_in_tree():
			inventory._select_first_item()


func remove_item(item_id: String) -> void:
	if item_id == "":
		return

	# Wenn ein PIECE entfernt wird, Count der Gruppe mit runter zählen
	var group := _get_stack_group(item_id)
	if group != "":
		var new_count: int = int(hotbar_counts.get(group, 0)) - 1
		if new_count <= 0:
			hotbar_counts.erase(group)
			hotbar_icon_override.erase(group)
		else:
			hotbar_counts[group] = new_count

	var changed := false

	# remove from inventory
	for i in range(inventory_items.size()):
		if inventory_items[i] == item_id:
			inventory_items[i] = null
			changed = true
			break

	# complete empty slots with next items
	if changed:
		_compact_array(inventory_items)

	update_ui()


func _compact_array(arr: Array) -> void:
	var out: Array = []
	for v in arr:
		if v != null:
			out.append(v)
	while out.size() < arr.size():
		out.append(null)

	# copy content back
	for i in range(arr.size()):
		arr[i] = out[i]


# Hotbar ist eine VIEW:
# 1) Stack-Oberbegriffe (wenn count > 0) in fester Reihenfolge
# 2) Danach normale Inventory-Items, aber:
#    - pieces (stack_group != "") NICHT direkt in Hotbar anzeigen
#    - show_in_hotbar=false NICHT anzeigen
func get_hotbar_item(slot: int) -> Variant:
	if slot < 0 or slot >= 4:
		return null

	var list: Array = []

	# 1) Stack-Oberbegriffe
	for g in hotbar_stack_order:
		if int(hotbar_counts.get(g, 0)) > 0:
			list.append(g)

	# 2) Normale Items aus Inventory
	for v in inventory_items:
		if v == null:
			continue
		var id := String(v)

		# pieces nicht in Hotbar
		if _get_stack_group(id) != "":
			continue

		if not _show_in_hotbar(id):
			continue

		list.append(id)

	return list[slot] if slot < list.size() else null


func get_inventory_item(slot: int) -> Variant:
	return inventory_items[slot] if slot >= 0 and slot < inventory_items.size() else null


func get_hotbar_index_of_item(item_id: String) -> int:
	for i in range(4):
		if get_hotbar_item(i) == item_id:
			return i
	return -1


func has_item(item_id: String) -> bool:
	# im Inventory?
	if inventory_items.has(item_id):
		return true
	# oder ist es ein Oberbegriff mit count?
	if int(hotbar_counts.get(item_id, 0)) > 0:
		return true
	return false
