extends CanvasLayer

@export var puzzle_id: String = ""  
@onready var npc_porcini: NpcDialogProcessPorcini = $"../NPC_porcini"
@onready var fire_mush: FireMushroom = $"../FireMush"

@onready var mushroom_ui: CanvasLayer = $"."
@onready var champi: TextureRect = $sun/champi
@onready var truffle: TextureRect = $moon/truffle
@onready var porcini: TextureRect = $planet/porcini
@onready var mushrooms: Node2D = $mushrooms

@onready var truffle_socket: Sprite2D = $"../truffle_socket/mushroom_socket"
@onready var porcini_socket: Sprite2D = $"../porcini_socket/mushroom_socket"
@onready var champi_socket: Sprite2D = $"../champi_socket/mushroom_socket"

@onready var truffle_solved_tex: Texture2D = preload("res://assets/sprites/selfmade/mushrooms/solved_truffle.png")
@onready var champi_solved_tex: Texture2D = preload("res://assets/sprites/selfmade/mushrooms/solved_champi.png")
@onready var porcini_solved_tex: Texture2D = preload("res://assets/sprites/selfmade/mushrooms/solved_porcini.png")

@onready var mush_nodes := {
	"green_mush":  $mushrooms/green_mush,
	"blue_mush":   $mushrooms/blue_mush,
	"red_mush":    $mushrooms/red_mush,
	"yellow_mush": $mushrooms/yellow_mush,
	"orange_mush": $mushrooms/orange_mush,
	"brown_mush":  $mushrooms/brown_mush,
}
@onready var porcini_solved: Texture2D = preload("res://assets/sprites/portrait/porcini.png")
@onready var champi_solved: Texture2D = preload("res://assets/sprites/portrait/champignon.png")
@onready var truffle_solved: Texture2D = preload("res://assets/sprites/portrait/truffle.png")

var solved = false
var fill_order: Array = []

func _ready() -> void:
	if GameState.puzzle_state.get(puzzle_id, false):
		solved = true
		is_solved()
		solved_layout()


func open_socket():
	mushroom_ui.show()
	
	for slot in get_tree().get_nodes_in_group("socket"):
		slot.manager = self

	if GameState.puzzle_state.get(puzzle_id, false):
		solved = true
		is_solved()
		solved_layout()
		return

	check_mush()
	check_puzzle()


#checks if mushrooms in inventory
func check_mush():
	for id in mush_nodes.keys():
		mush_nodes[id].visible = hotbarglobal.has_item(id)

func on_slot_filled(slot):
	if not fill_order.has(slot):
		fill_order.append(slot)
	check_puzzle()

func on_slot_cleared(slot):
	fill_order.erase(slot)

func correct_order(slot) -> bool:
	var wanted = slot.required_order_index
	var idx = fill_order.find(slot) + 1 
	return idx == wanted

func check_puzzle():
	var sockets = get_tree().get_nodes_in_group("socket")
#return if not every slot is occupied
	for socket in sockets:
			if not socket.is_occupied():
				return

	for socket in sockets:
		if not socket.is_correct():
			reset_all_sockets()
			return

	if not solved:
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true
		solved = true
		for id in mush_nodes.keys():
			var mushrooms_id: String = "mushrooms"
			hotbarglobal.remove_item(id)
			hotbarglobal.remove_item(mushrooms_id)
		SaveSystem.save_game()
		is_solved()

func reset_all_sockets():
	fill_order.clear()
	var side_slots = get_tree().get_nodes_in_group("side_slots")
	var pulled_pieces: Array[Area2D] = []

	for slot in get_tree().get_nodes_in_group("socket"):
		var p = slot.take_piece()
		if p:
			pulled_pieces.append(p)

	for piece in pulled_pieces:
		var target = _find_free_side_slot(side_slots)
		if target:
			target.set_piece(piece)
			piece.scale = piece.side_scale


func _find_free_side_slot(side_slots: Array) -> Area2D:
	for s in side_slots:
		if not s.is_occupied():
			return s
	return null


func is_solved():
	porcini.texture = porcini_solved
	champi.texture = champi_solved
	truffle.texture = truffle_solved
	
	truffle_socket.texture = truffle_solved_tex
	porcini_socket.texture = porcini_solved_tex
	champi_socket.texture = champi_solved_tex
	
	solved_layout()


func solved_layout():
	# set mushrooms when solved 
	for slot in get_tree().get_nodes_in_group("socket"):
		var piece := find_piece_by_id(slot.required_piece_id)
		if piece:
			piece.scale = piece.sockel_scale
			slot.set_piece(piece)
			piece.visible = true


	# hide other mushrooms
	for mush in get_tree().get_nodes_in_group("mushrooms"):
		var in_socket = mush.current_slot != null and mush.current_slot.is_in_group("socket")
		if not in_socket:
			mush.hide()


func find_piece_by_id(id: String) -> Area2D:
	for piece in get_tree().get_nodes_in_group("mushrooms"):
		if piece.piece_id == id:
			return piece
	return null


func _on_close_button_pressed() -> void:
	mushroom_ui.hide()

	var riddle_solved = solved or GameState.puzzle_state.get(puzzle_id, false)
	if not riddle_solved:
		return

	var key = puzzle_id + "_solved_dialog_shown"
	if GameState.puzzle_state.get(key, false):
		return

	GameState.puzzle_state[key] = true
	DialogManager.start_dialog("res://dialog/mushrooms/solved_riddle.json")
	DialogManager.dialog_finished.connect(_on_solved_dialog_finished, CONNECT_ONE_SHOT)


func _on_solved_dialog_finished():
	for npc in get_tree().get_nodes_in_group("mushroom_npc"):
		# final position npc
		npc.run_away_to(npc.global_position + Vector2(0,-190))
	
	fire_mush.get_mush()
	var key = puzzle_id + "_fire_mush_given"
	GameState.puzzle_state[key] = true
	
