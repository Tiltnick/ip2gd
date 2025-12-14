extends CanvasLayer

@export var puzzle_id: String = ""  
@onready var mushroom_ui: CanvasLayer = $"."

@onready var mushrooms: Node2D = $mushrooms
@onready var orange: Area2D = $mushrooms/orange_mush

@onready var mush_nodes := {
	"green_mush":  $mushrooms/green_mush,
	"blue_mush":   $mushrooms/blue_mush,
	"red_mush":    $mushrooms/red_mush,
	"yellow_mush": $mushrooms/yellow_mush,
	"orange_mush": $mushrooms/orange_mush,
	"brown_mush":  $mushrooms/brown_mush,
}

var solved = false
var fill_order: Array = []

#func open_socket():
	#mushroom_ui.show()
	#for slot in get_tree().get_nodes_in_group("socket"):
		#slot.manager = self
	#if not GameState.puzzle_state.get(puzzle_id, false) and solved == false:
		#var mushrooms = get_tree().get_nodes_in_group("mushrooms")
		#for piece in mushrooms:
			#piece.mush_released.connect(check_puzzle)
		#check_mush()
	#elif GameState.puzzle_state.get(puzzle_id, false):
			#solved = true
func open_socket():
	mushroom_ui.show()

	for slot in get_tree().get_nodes_in_group("socket"):
		slot.manager = self

	if GameState.puzzle_state.get(puzzle_id, false):
		solved = true
		return

	check_mush()
	check_puzzle()


#checks if mushrooms in inventory
func check_mush():
	for id in mush_nodes.keys():
		mush_nodes[id].visible = hotbarglobal.has_item(id)

func on_slot_filled(slot):
	# nur beim ersten Mal in die Reihenfolge
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
			print("falscher socket")
			return

	if not solved:
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true
		solved = true
		print("gelöst")
		for id in mush_nodes.keys():
			mush_nodes[id].visible = hotbarglobal.has_item(id)
			@warning_ignore("shadowed_variable")
			var mushrooms: String = "mushrooms"
			hotbarglobal.remove_item(id)
			hotbarglobal.remove_item(mushrooms)
			GameState.puzzle_state[id] = false
		

#func _on_close_button_pressed() -> void:
#	puzzle.hide()
