extends Control

@export var piece_id: String
@export var rotation_steps = 4

var dragging = false
var drag_offset = Vector2.ZERO #null vector
var current_slot = null 

func _ready() -> void:
	pass # Replace with function body.

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: #mouse pressed
			dragging = true
			drag_offset = event.position
		else: #mouse let go
			dragging = false
			assign_to_slot()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		rotate_piece()

func assign_to_slot():
	var overlapping = get_tree().get_nodes_in_group("puzzle_slots")
	for slot in overlapping:
		if slot.get_overlapping_areas().has(self):
			global_position = slot.global_position
			slot.current_piece = self
			current_slot = slot
			return
		
	current_slot = null #didn't hit slot

func rotate_piece():
	rotation_degrees = (rotation_degrees + (360/rotation_steps)) % 360

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
