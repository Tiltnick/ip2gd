extends Control

var slots = []

func _ready():
	var display = find_child("Display", true, false)
	if display:
		slots = display.get_children()
	else:
		print("Display-Node nicht gefunden!")

	hotbarglobal.inventory = self

	# Slots indizieren & Signale verbinden
	for i in range(slots.size()):
		if slots[i].has_method("set_item_icon"):
			slots[i].slot_index = i
			slots[i].connect("pressed", Callable(self, "_on_slot_pressed"))

	update_slots()






func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()
			
			
func _on_slot_pressed(index):
	print("Slot wurde geklickt:", index)
	var item_id = hotbarglobal.inventory_items[index]
	if not item_id:
		return

	if not ItemDatabase.DATA.has(item_id):
		return

	var data = ItemDatabase.DATA[item_id]

	# Title & Text updaten
	$Description/Title.text = data["name"]
	$Description/Text.text = data["description"]

	# Icon in Slot17 anzeigen
	$Description/Slot17.set_item_icon(item_id)
