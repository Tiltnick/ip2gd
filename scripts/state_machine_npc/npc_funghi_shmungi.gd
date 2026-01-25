extends NPC
class_name NpcDialogProcessFunghi

const DIALOG_BY_SCENE := {
	"Outside1": "res://dialog/mushrooms/funghi_shmunghi.json",
}
const DEFAULT_DIALOG := "res://dialog/mushrooms/funghi_shmunghi.json"

func _ready() -> void:
	super._ready()

func get_dialog_path(scene_name: String) -> String:
	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)
