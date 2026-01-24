extends Area2D

signal mush_released

@export var sockel_scale := Vector2(1, 1)
@export var side_scale := Vector2(0.5, 0.5)
@export var piece_id: String
@export var start_slot_path: NodePath

static var active_drag_piece: Area2D = null
var dragging := false
var drag_offset := Vector2.ZERO
var current_slot = null

var start_slot: Area2D = null
var start_position: Vector2


func _ready():
	input_pickable = true
	scale = side_scale
	
	start_position = global_position
	if start_slot_path != NodePath(""):
		start_slot = get_node_or_null(start_slot_path)

func return_to_start():
	dragging = false
	if active_drag_piece == self:
		active_drag_piece = null
	scale = side_scale
	if start_slot and not start_slot.is_occupied():
		start_slot.set_piece(self)
	else:
		global_position = start_position

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if active_drag_piece != null:
				return
			active_drag_piece = self
			z_index = 1
			scale = sockel_scale  
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else: #mouse released
			if active_drag_piece == self:
				active_drag_piece = null
			dragging = false
			z_index = 0
			try_assign_to_slot()
			emit_signal("mush_released")

func try_assign_to_slot():
	var socket = get_tree().get_nodes_in_group("socket")
	var side_slots = get_tree().get_nodes_in_group("side_slots")
	var next_puzzle_piece: Area2D = null
	var puzzle_dist = 100.0
	var next_side_slot: Area2D= null
	var side_dist = 50.0

	# finding nearest slot for puzzle piece
	for slot in socket:
		var d = global_position.distance_to(slot.global_position)
		if d < puzzle_dist:
			next_puzzle_piece = slot
			puzzle_dist = d
	# finding nearest side slot
	for slot in side_slots:
		var d = global_position.distance_to(slot.global_position)
		if d < side_dist:
			next_side_slot = slot
			side_dist = d
	if current_slot:
		current_slot.clear()
		current_slot = null
	if next_puzzle_piece and not next_puzzle_piece.is_occupied():
		next_puzzle_piece.set_piece(self)
	elif next_side_slot and not next_side_slot.is_occupied():
		next_side_slot.set_piece(self)
		scale = side_scale

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
