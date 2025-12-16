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
	
	#hotbar icon auf das zuletzt eingesammelte setzen
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

#func remove_item(item_id: String) -> void:
	## remove from inventory
	#for i in range(inventory_items.size()):
		#if inventory_items[i] == item_id:
			#inventory_items[i] = null
			#return
#
	## remove from hotbar
	#for i in range(hotbar_items.size()):
		#if hotbar_items[i] == item_id:
			#hotbar_items[i] = null
			#return
	#update_ui()
	

func remove_item(item_id: String) -> void:
	if item_id == "":
		return

	var changed := false

	# Inventory erstes Vorkommen löschen
	for i in range(inventory_items.size()):
		if inventory_items[i] == item_id:
			inventory_items[i] = null
			changed = true
			break

	# Hotbar erstes Vorkommen löschen
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == item_id:
			hotbar_items[i] = null
			changed = true
			break

	# Nachrücken
	if changed:
		hotbar_counts.erase(item_id)
		hotbar_icon_override.erase(item_id)
		_compact_array(inventory_items)
		_compact_array(hotbar_items)

	update_ui()


func _compact_array(arr: Array) -> void:
	var out: Array = []
	for v in arr:
		if v != null:
			out.append(v)
	while out.size() < arr.size():
		out.append(null)

	# Inhalte zurückkopieren
	for i in range(arr.size()):
		arr[i] = out[i]



func get_item_from_hotbar(slot: int) -> String:
	return hotbar_items[slot] if slot < hotbar_items.size() else null

func get_inventory_item(slot: int) -> String:
	return inventory_items[slot] if slot < inventory_items.size() else null

func get_hotbar_index_of_item(item_id: String) -> int:
	return hotbar_items.find(item_id)

func has_item(item_id: String) -> bool:
	return inventory_items.has(item_id) or hotbar_items.has(item_id)
