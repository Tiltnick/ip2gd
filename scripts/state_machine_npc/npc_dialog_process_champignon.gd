extends NPC
class_name npc_dialog_process_champignon

# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside3": "res://dialog/mushrooms/mushroom.json",
}

func _ready() -> void:
	super._ready()

func get_dialog_path(scene_name: String) -> String:
	var dialog_path := ""

	if scene_name == "Outside3":
		if not GameState.puzzle_state.get("mushroom_dialog_done", false):
			dialog_path = "res://dialog/mushrooms/mushroom.json"
		else:
			dialog_path = ""  
	else:
		if DIALOG_BY_SCENE.has(scene_name):
			dialog_path = DIALOG_BY_SCENE[scene_name]
		else:
			dialog_path = "res://dialog/mushrooms/mushroom.json"

	return dialog_path
