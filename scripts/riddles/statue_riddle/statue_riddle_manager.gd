extends CanvasLayer

@export var puzzle_id: String = "statue_puzzle"

@onready var bottom = $bottom
@onready var middle = $middle
@onready var top = $top

var solved := false

const SOLVED_DIALOG := "res://dialog/innerMonologue/completing_statue_riddle.json"
const TELESCOPE_CONSUMED_FLAG := "telescope_consumed_after_statue"


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
	SfxPlayer.puzzle_solved()
	solved = true

	# In GameState speichern
	if puzzle_id != "":
		GameState.puzzle_state[puzzle_id] = true

	print("Rätsel gelöst")

	# Alle Blöcke sperren
	bottom.lock()
	middle.lock()
	top.lock()
	
	call_deferred("_delayed_close_and_dialog")
	

	if not GameState.puzzle_state.get(TELESCOPE_CONSUMED_FLAG, false):
		GameState.puzzle_state[TELESCOPE_CONSUMED_FLAG] = true
		if hotbarglobal.has_item("telescope"):
			hotbarglobal.remove_item("telescope")


func _delayed_close_and_dialog() -> void:
	await get_tree().create_timer(1.0).timeout

	close_puzzle()

	#w1 frame warten bevor puzzle geschlossen wird
	await get_tree().process_frame

	DialogManager.start_dialog(SOLVED_DIALOG)


func _on_close_button_pressed() -> void:
	close_puzzle()
