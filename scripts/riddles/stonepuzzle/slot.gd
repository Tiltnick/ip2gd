extends Node2D
@export var required_piece_id : String
@export var required_rotation = 0
var current_piece = null

func is_correct() -> bool:
	if current_piece == null:
		return false
	var correct_piece = current_piece.piece_id == required_piece_id
	var correct_rot = int(current_piece.rotation_degrees) % 360 == required_rotation
	return correct_piece and correct_rot
