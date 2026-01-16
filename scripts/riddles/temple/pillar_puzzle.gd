extends Node
class_name PillarPuzzle

signal puzzle_solved

@export var solution: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
@export var reset_on_mistake: bool = true

@export var solved_flag: String = "outside5_pillar_puzzle_solved"
@export var failed_flag: String = "outside5_pillar_puzzle_failed"

@export var sam_group_name: String = "sam_state_machine"
@export var sam_failed_method: String = "on_puzzle_failed"

var _pillars_by_id: Dictionary = {}
var _input_index: int = 0
var _solved: bool = false

var _sam_target: Node = null


func _ready() -> void:
	_register_pillars()

	_sam_target = _find_sam_target()
	_connect_sam_signals()

	if _is_flag_true(solved_flag):
		_set_solved_state()
		return

	_solved = false
	_input_index = 0
	_reset_visuals()
	_set_pillars_locked(false)


# --- pillars ---
func _register_pillars() -> void:
	_pillars_by_id.clear()

	var nodes := get_tree().get_nodes_in_group("pillars")
	for n in nodes:
		if n is not Pillar:
			continue

		var p := n as Pillar
		if p.pillar_id.is_empty():
			continue

		_pillars_by_id[p.pillar_id] = p

		if not p.pressed.is_connected(_on_pillar_pressed):
			p.pressed.connect(_on_pillar_pressed)


func reset_puzzle() -> void:
	if _is_flag_true(solved_flag):
		_set_solved_state()
		return

	_solved = false
	_input_index = 0
	_reset_visuals()
	_set_pillars_locked(false)


# --- input ---
func _on_pillar_pressed(pillar: Pillar) -> void:
	if _solved:
		return
	if solution.is_empty():
		return
	if _input_index < 0 or _input_index >= solution.size():
		_fail_and_reset()
		return

	var expected_id := solution[_input_index]

	if pillar.pillar_id == expected_id:
		_accept_correct_input(pillar)
	else:
		if reset_on_mistake:
			_on_failed()


func _accept_correct_input(pillar: Pillar) -> void:
	pillar.set_on(true)
	_input_index += 1

	if _input_index >= solution.size():
		_on_solved()


# --- fail / solve ---
func _on_failed() -> void:
	_fail_and_reset()
	_set_flag(failed_flag, true)
	_set_pillars_locked(false)
	_notify_sam_failed()


func _fail_and_reset() -> void:
	_input_index = 0
	_reset_visuals()


func _on_solved() -> void:
	_solved = true

	_set_flag(solved_flag, true)
	_set_flag(failed_flag, false)

	_set_solved_state()
	puzzle_solved.emit()
	print("Temple solved")


func _set_solved_state() -> void:
	for p in _pillars_by_id.values():
		var pillar := p as Pillar
		pillar.set_on(true)
		pillar.set_locked(true)


func _reset_visuals() -> void:
	for p in _pillars_by_id.values():
		var pillar := p as Pillar
		pillar.set_on(false)


func _set_pillars_locked(locked: bool) -> void:
	for p in _pillars_by_id.values():
		var pillar := p as Pillar
		pillar.set_locked(locked)


# --- sam signals ---
func _connect_sam_signals() -> void:
	if _sam_target == null:
		return

	if _sam_target.has_signal("guide_started"):
		_sam_target.connect("guide_started", Callable(self, "_on_sam_guide_started"))
	if _sam_target.has_signal("guide_finished"):
		_sam_target.connect("guide_finished", Callable(self, "_on_sam_guide_finished"))


func _on_sam_guide_started() -> void:
	_set_pillars_locked(true)


func _on_sam_guide_finished() -> void:
	_set_pillars_locked(false)


# --- sam notify (duck typing) ---
func _notify_sam_failed() -> void:
	if _sam_target == null:
		_sam_target = _find_sam_target()
		_connect_sam_signals()
	if _sam_target == null:
		return

	if _sam_target.has_method(sam_failed_method):
		_sam_target.call(sam_failed_method)


func _find_sam_target() -> Node:
	var list := get_tree().get_nodes_in_group(sam_group_name)
	if list.is_empty():
		return null
	return list[0] as Node


# --- gamestate ---
func _is_flag_true(flag_key: String) -> bool:
	if flag_key.is_empty():
		return false
	return bool(GameState.puzzle_state.get(flag_key, false))


func _set_flag(flag_key: String, value: bool) -> void:
	if flag_key.is_empty():
		return
	GameState.puzzle_state[flag_key] = value
