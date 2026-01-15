extends NPC
class_name SamDialogProcess

const SEGMENT_INDEX_KEY: String = "sam_outside5_segment_index"
const FAILED_FLAG: String = "outside5_pillar_puzzle_failed"

const OUTSIDE5_DIALOGS := [
	"res://dialog/Sam_ghost/Sam.json",
	"res://dialog/Sam_ghost/Sam2.json",
	"res://dialog/Sam_ghost/Sam3.json",
]

const OUTSIDE5_FAILED_DIALOG := "res://dialog/Sam_ghost/SamFailed.json"

const OUTSIDE5_END := ""
const DEFAULT_DIALOG := ""

@onready var sam_state_machine: SamStateMachine = get_node_or_null("stateMachine") as SamStateMachine


func _ready() -> void:
	super._ready()

	if sam_state_machine == null:
		sam_state_machine = _find_sam_state_machine()


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
	return DEFAULT_DIALOG


func _get_outside5_dialog() -> String:
	if bool(GameState.puzzle_state.get(FAILED_FLAG, false)):
		return OUTSIDE5_FAILED_DIALOG

	var idx := int(GameState.puzzle_state.get(SEGMENT_INDEX_KEY, 0))

	if idx >= 0 and idx < OUTSIDE5_DIALOGS.size():
		return OUTSIDE5_DIALOGS[idx]

	return OUTSIDE5_END


func _find_sam_state_machine() -> SamStateMachine:
	var list := get_tree().get_nodes_in_group("sam_state_machine")
	if list.is_empty():
		return null
	return list[0] as SamStateMachine
