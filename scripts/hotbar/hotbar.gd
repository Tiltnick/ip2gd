extends Control

@onready var slots := $Background/HBoxContainer.get_children()
var selected_slot := 0

func _ready():
	#_update_visuals()
	hotbarglobal.hotbar = self
	update_slots()

func _unhandled_input(event):
	for i in range(4):
		if event.is_action_pressed("hotbar_%d" % (i+1)):
			selected_slot = i
			#_update_visuals()
			zoom_slot_item(i)  

#func _update_visuals():
	#for i in range(slots.size()):
		#if i == selected_slot:
			#slots[i].modulate = Color(1, 1, 1)
		#else:
			#slots[i].modulate = Color(0.6, 0.6, 0.6)
		#
func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.items[i]
		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()
		print("Slot ", i, " has item: ", item_id)
		
		# Border des Slots holen
		var border := slots[i].get_node("Border")
		if border:
			if item_id:  # Slot belegt
				border.modulate = Color(0.851, 0.816, 0.655, 1.0)  # gelb wenn slot belegt
			else:  # Slot leer
				border.modulate = Color(0.357, 0.83, 0.783, 1.0)  


func zoom_slot_item(slot_index: int):
	var item_id = hotbarglobal.items[slot_index]
	if not item_id:
		return
	
	if item_id == "photo":
		var photo_scene = preload("res://scenes/interactables/objects/photo.tscn")
		var photo = photo_scene.instantiate()
		get_tree().current_scene.add_child(photo)
		photo.global_position = get_viewport().get_visible_rect().size / 2
		photo.scale = Vector2(0.5, 0.5)
		photo.z_index = 100
		photo.hotbar_activate()  # ruft Zoom/Flip Logic auf, falls vorhanden
