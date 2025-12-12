extends CanvasLayer


@onready var solved_puzzle: TextureRect = $solvedPuzzle
@onready var pieces: Node2D = $Pieces
@export var puzzle_id: String = "stone_puzzle"  
@export var total_slots := 6

var solved = false

func _ready():
	var pieces = get_tree().get_nodes_in_group("puzzle_pieces")
	for piece in pieces:
		piece.piece_released.connect(check_puzzle)

	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			solved_puzzle.show()
			pieces.hide()
			

func check_puzzle():
	var slots = get_tree().get_nodes_in_group("puzzle_slots")
	if slots.size() != total_slots:
		return
	for slot in slots:
		var ok = slot.is_correct()
		if not ok:
			return
	if not solved:
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true
		solved = true
		$AnimationPlayer.play("solved_animation")
		
