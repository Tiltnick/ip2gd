extends NPC
class_name SamDialogProcess

# Szene -> Dialoge
const DIALOG_BY_SCENE := {
	"Outside5": "res://dialog/dialogueSam/memory_intro.json",
}


# Flow: mehrere Dialoge
const OUTSIDE5_FLOW := [
	{ 
		"flag": "", 
		
		"path": "res://dialog/Sam_ghost/Sam.json"
	},
	
]
const OUTSIDE5_END := ""

const DEFAULT_DIALOG := ""

func _ready() -> void:
	super._ready()

func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside5":
		return _get_outside5_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_outside5_dialog() -> String:
	for step in OUTSIDE5_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE5_END
