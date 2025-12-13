extends NPC
class_name NpcDialogProcessPorcini

# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside3": "res://dialog/mushrooms/porcini.json",
}

# Reihenfolge wichtig
const OUTSIDE3_FLOW := [
	{
		"flag": "mushroom_dialog_done",
		"path": "res://dialog/mushrooms/begin_porcini.json",
	},
]

const OUTSIDE3_END := "res://dialog/mushrooms/porcini.json"
const DEFAULT_DIALOG := "Kein Dialog gefunden"

func _ready() -> void:
	super._ready()

# Szene → Dialogdatei
func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside3":
		return _get_outside3_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_outside3_dialog() -> String:
	for step in OUTSIDE3_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step["path"]
	return OUTSIDE3_END
