extends Area2D

signal piece_released

@export var piece_id: String
@export var rotation_steps := 4

var dragging := false
var drag_offset := Vector2.ZERO
var current_slot = null


func _ready():
	input_pickable = true


# ✅ Wird NUR beim Klicken auf die Collision ausgelöst
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else:
			dragging = false
			try_assign_to_slot()
			emit_signal("piece_released")

func try_assign_to_slot():
	var slots = get_tree().get_nodes_in_group("puzzle_slots")
	var best_slot: Area2D = null
	var best_dist := 40  # SNAP-RADIUS (kannst du anpassen)

	for slot in slots:
		var d = global_position.distance_to(slot.global_position)
		if d < best_dist:
			best_slot = slot
			best_dist = d

	# ✅ Wenn schon im richtigen Slot, nichts tun
	if best_slot == current_slot:
		return

	# ✅ Alten Slot leeren
	if current_slot:
		current_slot.clear()
		current_slot = null

	# ✅ Neuen Slot setzen
	if best_slot:
		best_slot.set_piece(self)



# ✅ Läuft JEDES Frame → hier passiert das eigentliche Ziehen
func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
