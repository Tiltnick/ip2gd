extends CanvasLayer

@export var puzzle_id: String = "stone_puzzle"  
@onready var puzzle: CanvasLayer = $"."
@onready var solved_animation: AnimationPlayer = $solved_Animation

@onready var piece_1: Area2D = $Pieces/Piece1
@onready var piece_2: Area2D = $Pieces/Piece2
@onready var piece_3: Area2D = $Pieces/Piece3
@onready var piece_4: Area2D = $Pieces/Piece4
@onready var piece_5: Area2D = $Pieces/Piece5
@onready var piece_6: Area2D = $Pieces/Piece6

@onready var solved_puzzle: TextureRect = $solved_Puzzle2
@onready var pieces: Node2D = $Pieces
@onready var blob: NpcDialogProcessBlob = $"../NPC"

var solved = false


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
		
		

func check_pieces():
	for i in range(1, 7):
		var id = "stone_piece_%d" % i
		var node = $Pieces.get_node("Piece%d" % i)
		node.visible = hotbarglobal.has_item(id)

func check_puzzle():
	var slots = get_tree().get_nodes_in_group("puzzle_slots")

	for slot in slots:
		var ok = slot.is_correct()
		if not ok:
			return

	if not solved:
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true
		SfxPlayer.puzzle_solved()
		solved = true
		solved_animation.play("solved_animation")
		for i in range(1, 7):
			var id = "stone_piece_%d" % i
			var stonepanel: String = "stonepanel"
			hotbarglobal.remove_item(id)
			hotbarglobal.remove_item(stonepanel)
			blob.run_away_to(blob.global_position + Vector2(0, 550))

func _on_close_button_pressed() -> void:
	var key := puzzle_id + "_solved_dialog_shown" 
	puzzle.hide()
	if GameState.puzzle_state.has(puzzle_id) and not GameState.puzzle_state.get(key, false):
		GameState.puzzle_state[key] = true
		SaveSystem.save_game()
		DialogManager.start_dialog("res://dialog/innerMonologue/puzzle_solved.json")
