extends Area2D

@export var required_piece_id: String
@export var required_rotation := 0

var current_piece: Area2D = null


func clear():
	current_piece = null

func is_occupied() -> bool:
	return current_piece != null

func set_piece(piece: Area2D):
	current_piece = piece
	piece.current_slot = self
	piece.global_position = global_position
	piece.rotation_degrees = required_rotation


func is_correct() -> bool:
	if current_piece == null:
		return false
	var correct_piece = current_piece.piece_id == required_piece_id
	var correct_rot = snappedf(current_piece.rotation_degrees, 90) == required_rotation
	return correct_piece and correct_rot
