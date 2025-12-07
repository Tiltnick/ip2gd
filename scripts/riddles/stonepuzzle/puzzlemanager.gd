extends Control
signal puzzle_solved

@export var total_slots = 6
var solved = false

func check_puzzle():
	var slots = get_tree().get_nodes_in_group("puzzle_slots")
	for slot in slots:
		if not slot.is_correct():
			return
	if solved == false:
		solved = true
		emit_signal("puzzle_solved")
		print("Puzzle solved")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_puzzle()
