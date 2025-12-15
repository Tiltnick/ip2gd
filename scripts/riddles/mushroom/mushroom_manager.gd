extends CanvasLayer

@export var puzzle_id: String = ""  

@onready var mushroom_ui: CanvasLayer = $"."
@onready var champi: TextureRect = $sun/champi
@onready var truffle: TextureRect = $moon/truffle
@onready var porcini: TextureRect = $planet/porcini
@onready var mushrooms: Node2D = $mushrooms

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


func open_socket():
	mushroom_ui.show()

	for slot in get_tree().get_nodes_in_group("socket"):
		slot.manager = self

	if GameState.puzzle_state.get(puzzle_id, false):
		solved = true
		print("has saved")
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
	# wenn rausgezogen: aus Reihenfolge entfernen
	fill_order.erase(slot)

func correct_order(slot) -> bool:
	var wanted = slot.required_order_index
	var idx = fill_order.find(slot) + 1  # +1 weil find() ab 0 zählt
	return idx == wanted

func check_puzzle():
	var slots = get_tree().get_nodes_in_group("socket")

	for slot in slots:
		if not slot.is_correct():
			return

	if not solved:
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true
		solved = true
		print("gelöst")
		for id in mush_nodes.keys():
			
			var mushrooms_id: String = "mushrooms"
			hotbarglobal.remove_item(id)
			hotbarglobal.remove_item(mushrooms_id)

		is_solved()

func is_solved():
	porcini.texture = porcini_solved
	champi.texture = champi_solved
	truffle.texture = truffle_solved
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
