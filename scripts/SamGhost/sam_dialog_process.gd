extends NPC
class_name SamDialogProcess


const DIALOG_BY_SCENE := {
	"Outside5": "res://dialog/dialogueSam/memory_intro.json",
}

const OUTSIDE5_FLOW := [
	{
		"flag": "sam_outside5_first_dialog_done",
		"path": "res://dialog/Sam_ghost/Sam.json",
	},
]

const OUTSIDE5_END := ""
const DEFAULT_DIALOG := ""

@onready var sam_state_machine: SamStateMachine = $stateMachine


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	outline.visible = player_inside

	if player_inside:
		outline.frame = anim.frame

		if not dialog_active and Input.is_action_just_pressed("interact"):

			if sam_state_machine:
				sam_state_machine.notify_dialog_started_by_this_npc()

			if e_popup_node:
				e_popup_node.visible = false

			var scene: Node = get_tree().current_scene
			var scene_name: String = scene.name if scene != null else ""

			var dialog_path: String = get_dialog_path(scene_name)

			if dialog_path != "":
				DialogManager.start_dialog(dialog_path)
				dialog_active = true


func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside5":
		return _get_outside5_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)


func _get_outside5_dialog() -> String:
	for step: Dictionary in OUTSIDE5_FLOW:
		var flag: String = str(step.get("flag", ""))
		if flag == "":
			return str(step.get("path", ""))

		if not bool(GameState.puzzle_state.get(flag, false)):
			return str(step.get("path", ""))

	return OUTSIDE5_END
