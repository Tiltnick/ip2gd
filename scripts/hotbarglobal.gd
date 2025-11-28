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


#func add_item(item_id: String) -> void:
	## 1) Versuche zuerst Hotbar zu füllen
	#for i in range(hotbar_items.size()):
		#if hotbar_items[i] == null:
			#hotbar_items[i] = item_id
			#update_ui()
			#print("Hotbar item added to slot ", i)
			#return
#
	## 2) Hotbar voll → Inventory benutzen
	#for i in range(inventory_items.size()):
		#if inventory_items[i] == null:
			#inventory_items[i] = item_id
			#update_ui()
			#print("Inventory item added to slot ", i)
			#return
#
	#print("Kein Platz im Hotbar und Inventory!")
	
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
