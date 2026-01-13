extends Node
class_name SamDialogProcess

# Szene → Defaultdialog (Fallback)
const DIALOG_BY_SCENE := {
	"MemoryRoom": "res://dialog/dialogueSam/memory_intro.json",
}

# Beispiel-Flags (anpassen)
const MEMORY_INTRO_DONE := "sam_memory_intro_done"
const MEMORY_RULES_DONE := "sam_memory_rules_done"
const MEMORY_WIN_DONE := "sam_memory_win_done"

# Flow (mehrere Dialoge nacheinander)
const MEMORY_FLOW := [
	{ "flag": MEMORY_INTRO_DONE, "path": "res://dialog/dialogueSam/memory_intro.json" },
	{ "flag": MEMORY_RULES_DONE, "path": "res://dialog/dialogueSam/memory_rules.json" },
]
const MEMORY_END := "res://dialog/dialogueSam/memory_ready_to_walk.json"

const DEFAULT_DIALOG := "res://dialog/dialogueSam/default.json"

func get_dialog_path(scene_name: String) -> String:
	if scene_name == "MemoryRoom":
		return _get_memory_dialog()
	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_memory_dialog() -> String:
	for step in MEMORY_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return MEMORY_END
