extends Node
class_name Hotbarglobal

var items = [null, null, null, null]  
var hotbar: Control

func add_item(item_id: String) -> void:
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item_id
			if hotbar:
				hotbar.update_slots()
			print("Item added to slot ", i)
			return
		
	print("Keine freien Hotbar-Slots!")
	

func add_item_to_slot(slot: int, item_id: String):
	if slot >= 0 and slot < items.size():
		items[slot] = item_id

func activate_slot(slot: int):
	var item = items[slot]
	if item:
		print("Using item from slot ", slot, ": ", item)
