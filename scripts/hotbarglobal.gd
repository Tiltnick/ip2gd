extends Node
class_name Hotbarglobal

var items = [null, null, null, null]  
var hotbar: Control
var inventory: Control

func add_item(item_id: String) -> void:
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item_id
			if hotbar:
				hotbar.update_slots()
				
			if inventory:
				inventory.update_slots()
			print("Item added to slot ", i)
			return
	print("Keine freien Hotbar-Slots!")


func add_item_to_slot(slot: int, item_id: String):
	if slot >= 0 and slot < items.size():
		items[slot] = item_id


func activate_slot(slot: int) -> void:
	var item_id = items[slot]
	if not item_id:
		return

	print("Using item from slot %d: %s" % [slot, item_id])
	
	if item_id == "photo":
		var photo_scene = preload("res://scenes/interactables/objects/photo.tscn")
		var photo = photo_scene.instantiate()
		get_tree().current_scene.add_child(photo)
		photo.meta_slot_index = slot
		photo.hotbar_activate()
