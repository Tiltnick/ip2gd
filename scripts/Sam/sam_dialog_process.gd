extends Node
class_name SamDialogProcess

const DEFAULT_DIALOG := "Kein Dialog gefunden"

# normale Steps
const OUTSIDE5_DIALOGS := {
	1: "res://dialog/Sam_ghost/Sam.json",
	2: "res://dialog/Sam_ghost/Sam2.json",
	3: "res://dialog/Sam_ghost/Sam3.json",
}

# FAIL Dialog (wenn Puzzle falsch)
const OUTSIDE5_FAIL_DIALOG := "res://dialog/Sam_ghost/SamFailed.json"

const GUIDE_BY_DIALOG := {
	"res://dialog/Sam_ghost/Sam.json": {"guide_after": true, "guide_index": 1},
	"res://dialog/Sam_ghost/Sam2.json": {"guide_after": true, "guide_index": 2},
	"res://dialog/Sam_ghost/Sam3.json": {"guide_after": true, "guide_index": 3},

	# Fail dialog -> danach wieder Weg 1 zeigen
	"res://dialog/Sam_ghost/SamFailed.json": {"guide_after": true, "guide_index": 1},
}


func get_dialog_path_for_step(scene_name: String, step: int) -> String:
	if scene_name == "Outside5":
		return String(OUTSIDE5_DIALOGS.get(step, DEFAULT_DIALOG))
	return DEFAULT_DIALOG


func get_fail_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside5":
		return OUTSIDE5_FAIL_DIALOG
	return DEFAULT_DIALOG


func should_guide_after_dialog(_scene_name: String, dialog_path: String) -> bool:
	if not GUIDE_BY_DIALOG.has(dialog_path):
		return false
	return bool(GUIDE_BY_DIALOG[dialog_path].get("guide_after", false))


func get_guide_index_for_dialog(_scene_name: String, dialog_path: String) -> int:
	if not GUIDE_BY_DIALOG.has(dialog_path):
		return 1
	return int(GUIDE_BY_DIALOG[dialog_path].get("guide_index", 1))
