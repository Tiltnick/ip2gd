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
	var is_new_pickup := not GameState.picked_items.has(item_id)

	# Quest-Updates + Quest-Slots
	if is_new_pickup:
		GameState.picked_items.append(item_id)
		QuestManager.on_item_picked(item_id)
		if has_node("/root/AnalyticsLogger"):
			AnalyticsLogger.log_item_collected(item_id, {
				"source": "hotbar"
			})

	# damit items nicht doppelt gesaved werden
	if inventory_items.has(item_id):
		print("has id in add item")
		update_ui()
		push_to_gamestate()
		return true

	#füge item zu inventory zu 
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item_id
			update_ui()
			push_to_gamestate()
			return true

	#push_to_gamestate()
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

	
	hotbar_counts[hotbar_type_id] = int(hotbar_counts.get(hotbar_type_id, 0)) + 1
	hotbar_icon_override[hotbar_type_id] = piece_id

	update_ui()
	push_to_gamestate()



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
	if GameState.picked_items.has(item_id):
		GameState.picked_items.erase(item_id)
	var group := _get_stack_group(item_id)
	if group != "":
		var new_count: int = int(hotbar_counts.get(group, 0)) - 1
		if new_count <= 0:
			hotbar_counts.erase(group)
			hotbar_icon_override.erase(group)
		else:
			hotbar_counts[group] = new_count

	var changed := false

	# aus inventory löschen
	for i in range(inventory_items.size()):
		if inventory_items[i] == item_id:
			inventory_items[i] = null
			changed = true
			break

	# füll die nächsten leeren slots mit items auf
	if changed:
		_compact_array(inventory_items)

	update_ui()
	push_to_gamestate()



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


func get_hotbar_item(slot: int) -> Variant:
	if slot < 0 or slot >= 4:
		return null

	var list: Array = []
	var added_groups: Dictionary = {}

	
	for v in inventory_items:
		if v == null:
			continue

		var id := String(v)
		var group := _get_stack_group(id)

		
		if group != "":
			if not added_groups.has(group) and int(hotbar_counts.get(group, 0)) > 0:
				list.append(group)
				added_groups[group] = true
			continue

		
		if not _show_in_hotbar(id):
			continue

		list.append(id)

	# Fallback falls counts gesetzt sin baer keine piece
	for g in hotbar_counts.keys():
		if int(hotbar_counts.get(g, 0)) > 0 and not added_groups.has(g):
			list.append(g)

	return list[slot] if slot < list.size() else null



func get_inventory_item(slot: int) -> Variant:
	return inventory_items[slot] if slot >= 0 and slot < inventory_items.size() else null


func get_hotbar_index_of_item(item_id: String) -> int:
	for i in range(4):
		if get_hotbar_item(i) == item_id:
			return i
	return -1


func has_item(item_id: String) -> bool:
	# im Inventory
	if inventory_items.has(item_id):
		return true
	# oder es ist ein stackable
	if int(hotbar_counts.get(item_id, 0)) > 0:
		return true
	return false
	
	
func give_item(item_id: String, save_key: String = "") -> bool:
	if item_id == "":
		return false

	# einmalig vergwben
	if save_key != "" and bool(GameState.puzzle_state.get(save_key, false)):
		update_ui()
		return false

	# Item ins Inventar
	var added := add_item(item_id)
	if not added:
		return false

	# Save-State setzen
	if save_key != "":
		GameState.puzzle_state[save_key] = true
		
	push_to_gamestate()

	# Popup anzeigen
	_show_item_popup_from_db(item_id)

	return true


func _show_item_popup_from_db(item_id: String) -> void:
	if not ItemDatabase.DATA.has(item_id):
		return

	var data: Dictionary = ItemDatabase.DATA[item_id]
	var lang := TranslationServer.get_locale().substr(0, 2)

	var title: String = String(data.get("name_en", item_id))
	if lang == "de":
		title = String(data.get("name_de", item_id))

	
	var icon_path: String = String(data.get("icon", ""))
	if icon_path == "":
		return

	var tex := load(icon_path) as Texture2D
	if tex == null:
		return
	
	PopupManager.popup_item(title, tex)


func push_to_gamestate() -> void:
	GameState.inventory_slots = inventory_items.duplicate(true)
	GameState.hotbar_counts = hotbar_counts.duplicate(true)
	GameState.hotbar_icon_override = hotbar_icon_override.duplicate(true)

func pull_from_gamestate() -> void:
	
	if GameState.inventory_slots.is_empty():
		inventory_items = [
			null, null, null, null,
			null, null, null, null,
			null, null, null, null,
			null, null, null, null
		]
	else:
		inventory_items = GameState.inventory_slots.duplicate(true)

	hotbar_counts = GameState.hotbar_counts.duplicate(true)
	hotbar_icon_override = GameState.hotbar_icon_override.duplicate(true)

	update_ui()
