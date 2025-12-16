extends NPC
class_name NpcDialogProcessBlob

# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside1": "res://dialog/dialogueMrBlob/outside_1.json",
}

const OUTSIDE1_FLOW := [
	{
		"flag": "outside1_done",
		"path": "res://dialog/dialogueMrBlob/outside_1.json",
	}
]

const OUTSIDE1_END := ""

# Reihenfolge wichtig
const OUTSIDE2_FLOW := [
	{
		"flag": "blob_intro_done",
		"path": "res://dialog/dialogueMrBlob/outside_2_part_1.json",
	},
	{
		"flag": "blob_clue_done",
		"path": "res://dialog/cluesMrBlob/clue_stone_pile.json",
	},
	{
		"flag": "blob_revelation_done",
		"path": "res://dialog/dialogueMrBlob/outside_2_part_2.json",
	},
]

const OUTSIDE2_END := "res://dialog/dialogueMrBlob/end_dialog_outside2_blob.json"
const DEFAULT_DIALOG := "Kein Dialog gefunden"

func _ready() -> void:
	super._ready()

# Szene → Dialogdatei
func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside1":
		return _get_outside1_dialog()
	elif scene_name == "Outside2":
		return _get_outside2_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)
	
func _get_outside1_dialog() -> String:
	for step in OUTSIDE1_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step["path"]
	return OUTSIDE1_END
	
func _get_outside2_dialog() -> String:
	for step in OUTSIDE2_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step["path"]
	return OUTSIDE2_END
