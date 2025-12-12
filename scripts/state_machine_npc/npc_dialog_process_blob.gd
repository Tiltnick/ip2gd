extends NPC
class_name npc_dialog_process_blob

# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside1": "res://dialog/dialogueMrBlob/outside_1.json",
	"Outside2": "res://dialog/dialogueMrBlob/outside_2_part_1.json",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready() 


# Szene → Dialogdatei (überschreibt Hook aus NPC.gd)
func get_dialog_path(scene_name: String) -> String:
	var dialog_path: String = ""

	if scene_name == "Outside2":
		if not GameState.puzzle_state.get("blob_intro_done", false):
			dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_1.json"
		elif not GameState.puzzle_state.get("blob_clue_done", false):
			dialog_path = "res://dialog/cluesMrBlob/clue_stone_pile.json"
		elif not GameState.puzzle_state.get("blob_revelation_done", false):
			dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_2.json"

	else:
		if DIALOG_BY_SCENE.has(scene_name):
			dialog_path = DIALOG_BY_SCENE[scene_name]
		else:
			dialog_path = "res://dialog/dialogueMrBlob/outside_1.json"

	return dialog_path
