extends Area2D
@export var required_piece_id: String
@export var required_order_index: int = 0

var manager: Node = null
var current_piece: Area2D = null

func clear():
	if manager:
		manager.on_slot_cleared(self)
	current_piece = null

func is_occupied() -> bool:
	return current_piece != null

func take_piece() -> Area2D:
	var p := current_piece
	if p:
		p.current_slot = null
	current_piece = null
	if manager:
		manager.on_slot_cleared(self)
	return 

func set_piece(piece: Area2D):
	current_piece = piece
	piece.current_slot = self
	piece.global_position = global_position
	if manager:
		manager.on_slot_filled(self)

func is_correct() -> bool:
	if current_piece == null:
		return false

	if current_piece.piece_id != required_piece_id:
		return false

	if required_order_index > 0 and manager:
		return manager.correct_order(self)

	return true
	
