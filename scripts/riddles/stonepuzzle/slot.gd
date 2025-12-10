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


func is_correct() -> bool:
	if current_piece == null:
		return false

	var correct_piece = current_piece.piece_id == required_piece_id

	var steps: int = int(current_piece.rotation_steps)
	var step_angle: float = 360.0 / steps

	# ✅ NUR eine saubere Rundung, kein snappedf-Chaos
	var current_step: int = int(round(current_piece.rotation_degrees / step_angle)) % steps

	var correct_rot := current_step == required_rotation

	# 🔍 DEBUG (WICHTIG!)
	print("ROT:", current_piece.rotation_degrees,
		  " STEP:", current_step,
		  " REQUIRED:", required_rotation)

	return correct_piece and correct_rot
