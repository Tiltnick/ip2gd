extends Interactable
@onready var puzzle: CanvasLayer = $"../TempleDoorRiddle"

func _ready() -> void:
	super._ready()
func interact():
	SfxPlayer.ui_click_sound()
	puzzle.open_puzzle()
	
func open_puzzle():
	puzzle.show()
	#checks if puzzle pieces are on right spot when released
	if not GameState.puzzle_state.get(puzzle_id, false) and solved == false:
		var puzzle_pieces = get_tree().get_nodes_in_group("puzzle_pieces")
		for piece in puzzle_pieces:
			piece.piece_released.connect(check_puzzle)
		check_pieces()
	#puzzle already solved ?
	elif GameState.puzzle_state.has(puzzle_id):
		print("solved puzel")
		solved_puzzle.show()
		pieces.hide()
		solved = true
