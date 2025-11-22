extends Control

@onready var slots := $Background/HBoxContainer.get_children()

var selected_slot := 0

func _ready():
	hotbarglobal.hotbar = self  
	update_slots()
	_update_visuals()


func _unhandled_input(event):
	for i in range(4):
		if event.is_action_pressed("hotbar_%d" % (i+1)):
			selected_slot = i
			_update_visuals()
			hotbarglobal.activate_slot(i)

func _update_visuals():
	for i in range(slots.size()):
		if i == selected_slot:
			slots[i].modulate = Color(1, 1, 1)
		else:
			slots[i].modulate = Color(0.6, 0.6, 0.6)

func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.items[i]
		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()
		print("Slot ", i, " has item: ", item_id)
