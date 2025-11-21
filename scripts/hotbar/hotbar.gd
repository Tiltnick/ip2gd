extends Control

@onready var slots := $HBoxContainer.get_children()

var selected_slot := 0

func _ready():
	_update_visuals()

func _unhandled_input(event):
	for i in range(4):
		if event.is_action_pressed("hotbar_%d" % (i+1)):
			selected_slot = i
			_update_visuals()
			Hotbarglobal.activate_slot(i)

func _update_visuals():
	for i in range(slots.size()):
		if i == selected_slot:
			slots[i].modulate = Color(1, 1, 1)
		else:
			slots[i].modulate = Color(0.6, 0.6, 0.6)
