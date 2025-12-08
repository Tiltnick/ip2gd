extends Control
signal puzzle_solved

@export var total_slots := 6
var solved := false

func _ready():
	var pieces = get_tree().get_nodes_in_group("puzzle_pieces")

	for piece in pieces:
		piece.piece_released.connect(check_puzzle)

func check_puzzle():
	print(" check_puzzle")

	var slots = get_tree().get_nodes_in_group("puzzle_slots")
	print("Slots gefunden:", slots.size())

	if slots.size() != total_slots:
		return

	for slot in slots:
		var ok = slot.is_correct()
		print( slot.name, ":", ok)

		if not ok:
			print(" FEHLERHAFTER SLOT:", slot.name)
			return

	if not solved:
		solved = true
		print(" PUZZLE GELÖST ")
		emit_signal("puzzle_solved")
