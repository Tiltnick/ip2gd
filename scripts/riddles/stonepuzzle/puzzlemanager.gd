extends CanvasLayer



@export var puzzle_id: String = "stone_puzzle"  
@export var total_slots := 6
@onready var puzzle: CanvasLayer = $"."
@onready var solved_animation: AnimationPlayer = $solved_Animation

@onready var piece_1: Area2D = $Pieces/Piece1
@onready var piece_2: Area2D = $Pieces/Piece2
@onready var piece_3: Area2D = $Pieces/Piece3
@onready var piece_4: Area2D = $Pieces/Piece4
@onready var piece_5: Area2D = $Pieces/Piece5
@onready var piece_6: Area2D = $Pieces/Piece6

@onready var solved_puzzle: TextureRect = $solved_Puzzle
@onready var pieces: Node2D = $Pieces

var solved = false

func _ready():
	GameState.puzzle_state[puzzle_id] = false

func open_puzzle():
	puzzle.show()
	
	#if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		#print("ich bin im ersten if")
	if not GameState.puzzle_state.get(puzzle_id, false):
		var puzzle_pieces = get_tree().get_nodes_in_group("puzzle_pieces")
		for piece in puzzle_pieces:
			piece.piece_released.connect(check_puzzle)
		check_pieces()
	elif GameState.puzzle_state.get(puzzle_id, false):
			print("ich bin im zweiten if")
			solved_puzzle.show()
			pieces.hide()
			solved = true
		
		

func check_pieces():
	for i in range(1, 7):
		var id := "stone_piece_%d" % i
		var node := $Pieces.get_node("Piece%d" % i)
		node.visible = hotbarglobal.has_item(id)

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
		solved_animation.play("solved_animation")
		print("puzzle_state jetzt:", GameState.puzzle_state)

func _on_close_button_pressed() -> void:
	puzzle.hide()
