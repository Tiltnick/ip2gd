extends Node
class_name ColorCodeManager

@export var puzzle_id: String = "color_code_2151"
@export var correct: Array[int] = [2, 1, 5, 1]

var current: Array[int] = [0, 0, 0, 0]

func _ready() -> void:

	if GameState.puzzle_state.get(puzzle_id, false):
		current = correct.duplicate()
		return

	for i in range(4):
		var key := "%s_lamp_%d" % [puzzle_id, i]
		current[i] = int(GameState.puzzle_state.get(key, 0))

	# über gruppe nodes getten
	for n in get_tree().get_nodes_in_group("color_lamp"):
		if n is ColorLamp:
			_register_lamp(n)

func _register_lamp(lamp: ColorLamp) -> void:
	if lamp.lamp_index >= 0 and lamp.lamp_index < current.size():
		current[lamp.lamp_index] = lamp.value

	var cb := Callable(self, "_on_lamp_changed")
	if not lamp.is_connected("lamp_changed", cb):
		lamp.connect("lamp_changed", cb)

func _on_lamp_changed(index: int, value: int) -> void:
	current[index] = value
	_check_code()

func _check_code() -> void:
	if current == correct:
		GameState.puzzle_state[puzzle_id] = true
		print("Farb-Rätsel gelöst! Code =", current)
		_on_puzzle_completed()
		
		
func _on_puzzle_completed():
	SfxPlayer.puzzle_solved()
	DialogManager.start_dialog("res://dialog/innerMonologue/completing_lamp_riddle.json")
