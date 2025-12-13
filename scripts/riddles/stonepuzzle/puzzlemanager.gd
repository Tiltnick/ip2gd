extends CanvasLayer


@onready var solved_puzzle: TextureRect = $solvedPuzzle
@onready var pieces: Node2D = $Pieces
@export var puzzle_id: String = "stone_puzzle"  
@export var total_slots := 6
@onready var puzzle: CanvasLayer = $"."
@onready var piece_1: Area2D = $Pieces/Piece1


var solved = false

func _ready():
	var pieces = get_tree().get_nodes_in_group("puzzle_pieces")
	for piece in pieces:
		piece.piece_released.connect(check_puzzle)
	check_pieces()

	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			solved_puzzle.show()
			pieces.hide()
			

func check_pieces():
	if hotbarglobal.inventory_items.has("stone_piece_1"):
		piece_1.show()

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
		


func _on_close_button_pressed() -> void:
	puzzle.hide()
