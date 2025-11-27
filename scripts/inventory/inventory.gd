extends Control

@onready var slots := $Background/HBoxContainer.get_children()
var selected_slot := 0

# Szene vorladen
var photo_scene := preload("res://scenes/interactables/objects/photo.tscn")

# Aktuelles Item
var active_item: Node = null

# Selbst registrieren
func _ready():
	hotbarglobal.hotbar = self
	update_slots()


func _unhandled_input(event):
	# 1-4 Tasten auswählen für benutzen
	for i in range(slots.size()):
		if event.is_action_pressed("hotbar_%d" % (i + 1)):
			selected_slot = i
			_update_selected_visuals()
			use_slot(i)

# Item ID aus Hotbar/Inventar
func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.items[i]
		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()

		var border := slots[i].get_node("Border")
		if border:
			if item_id:  # Slot belegt
				border.modulate = Color(0.851, 0.816, 0.655, 1.0) 
			else:        # Slot leer
				border.modulate = Color(0.357, 0.83, 0.783, 1.0)  

	_update_selected_visuals()


func _update_selected_visuals():
	for i in range(slots.size()):
		var border := slots[i].get_node("Border")
		if border == null:
			continue

		if i == selected_slot:
		# Ausgewählter Slot
			border.self_modulate = Color(1, 1, 1, 1)
		else:
			border.self_modulate = Color(0.7, 0.7, 0.7, 1)


func use_slot(slot_index: int):
	var item_id = hotbarglobal.items[slot_index]
	if not item_id:
		return

	# Interact mit active item
	if active_item and is_instance_valid(active_item):
		if active_item.has_method("interact"):
			active_item.interact()
		return


	if item_id == "photo":
		var photo: Photo = photo_scene.instantiate()

		photo.spawned_from_hotbar = true

		get_tree().current_scene.add_child(photo)

		active_item = photo  
		photo.hotbar_scale = Vector2(0.5, 0.5)


		photo.hotbar_activate()
