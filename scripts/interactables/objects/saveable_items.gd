extends Interactable
# für die Interaktion
class_name SaveableItem

# Eindeutige ID zugewiesen
var save_id: String = ""

func _ready() -> void:
# super._ready() -> ready Funktion von Interactable
	super._ready()

# Check im GameState
	if save_id != "" and GameState.puzzle_state.get(save_id, false):
		queue_free()

# Eintrag in puzzle_state
func mark_collected() -> void:
	if save_id != "":
		GameState.puzzle_state[save_id] = true
