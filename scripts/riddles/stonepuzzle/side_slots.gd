extends Area2D

var current_piece = null

func clear():
	current_piece = null

func is_occupied() -> bool:
	return current_piece != null

func set_piece(piece):
	current_piece = piece
	piece.current_slot = self
	piece.global_position = global_position
