extends Node
class_name Hotbarglobal

var items = [null, null, null, null]

func add_item_to_slot(slot, item_id):
	items[slot] = item_id

func activate_slot(slot):
	var item = items[slot]
	if item:
		print("Using item: ", item)
