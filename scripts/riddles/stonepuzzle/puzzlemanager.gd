extends Control

@onready var solved_puzzle: TextureRect = $TextureRect2
@onready var pieces: Node2D = $Pieces

@export var total_slots := 6

var solved := false

func _ready():
	var pieces = get_tree().get_nodes_in_group("puzzle_pieces")
	for piece in pieces:
		piece.piece_released.connect(check_puzzle)

func check_puzzle():
	var slots = get_tree().get_nodes_in_group("puzzle_slots")
	if slots.size() != total_slots:
		return
	for slot in slots:
		var ok = slot.is_correct()
		if not ok:
			return
	if not solved:
		solved = true
		solved_puzzle.show()
		pieces.hide()
