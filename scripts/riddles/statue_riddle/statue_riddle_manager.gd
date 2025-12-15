extends CanvasLayer

@export var puzzle_id: String = "statue_puzzle"

@onready var bottom = $bottom
@onready var middle = $middle
@onready var top = $top

var solved := false

# Lösung:
# bottom idle = 4
# middle idle = 4
# top idle = 2

func _ready() -> void:
	hide()

func open_puzzle() -> void:
	show()

	# Falls Puzzle schon gelöst war (aus GameState)
	if GameState.puzzle_state.get(puzzle_id, false):
		solved = true
		bottom.lock()
		middle.lock()
		top.lock()

func close_puzzle() -> void:
	hide()

func _process(_delta: float) -> void:
	if not visible:
		return
	if solved:
		return

	if _is_solution_correct():
		_on_puzzle_solved()

func _is_solution_correct() -> bool:
	return (
		bottom.get_idle_frame() == 4
		and middle.get_idle_frame() == 4
		and top.get_idle_frame() == 2
	)

func _on_puzzle_solved() -> void:
	solved = true

	# In GameState speichern
	if puzzle_id != "":
		GameState.puzzle_state[puzzle_id] = true

	print("Rätsel gelöst")

	# Alle Blöcke sperren
	bottom.lock()
	middle.lock()
	top.lock()

func _on_close_button_pressed() -> void:
	close_puzzle()
