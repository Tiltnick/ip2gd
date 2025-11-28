extends Control

var slots = []

func _ready():
	slots = find_child("Display", true, false).get_children()
	hotbarglobal.inventory = self
	# Items anzeigen, auch wenn sie vorher gesammelt wurden
	update_slots()





func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()
