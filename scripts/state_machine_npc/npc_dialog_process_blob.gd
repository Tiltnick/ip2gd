extends NPC
class_name NpcDialogProcessBlob

var fleeing := false
var flee_target := Vector2.ZERO
@export var npc_id: String = "blob"
@export
var required_item_id: String = "shovel"

const OUTSIDE2_SECOND_UNLOCK_FLAG: String = "outside2_second_unlocked"

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
const OUTSIDE1_END: String = "res://dialog/dialogueMrBlob/outside_1_end.json"

const OUTSIDE2_FLOW := [
	{
		"flag": "blob_intro_done",
		"path": "res://dialog/dialogueMrBlob/outside_2_part_1.json",
	},
	{
		"flag": "blob_clue_done",
		"path": "res://dialog/cluesMrBlob/clue_stone_pile.json",
	},
]
const OUTSIDE2_END: String = "res://dialog/cluesMrBlob/clue_stone_pile_end.json"

const DEFAULT_DIALOG: String = "res://dialog/dialogueMrBlob/outside_2_part_2_default.json"

const OUTSIDE2_SECOND_FLOW := [
	{
		"flag": "blob_revelation_done",
		"path": "res://dialog/dialogueMrBlob/outside_2_part_2.json",
	}
]
const OUTSIDE2_SECOND_END: String = "res://dialog/dialogueMrBlob/outside_2_part_2_end.json"

const OUTSIDE2_LOCKED_WITH_ITEM_DIALOG: String = "res://dialog/dialogueMrBlob/outside_2_part_2_default.json"

const OUTSIDE3_FLOW := [
	{
		"flag": "blob_clue1_done",
		"path": "res://dialog/cluesMrBlob/clue_stone_panel_completion.json",
	}
]

const OUTSIDE3_SECOND_FLOW := [
	{
		"flag": "blob_clue2_done",
		"path": "res://dialog/cluesMrBlob/clue_mushroom_1.json",
	},
	{
		"flag": "blob_clue3_done",
		"path": "res://dialog/cluesMrBlob/clue_mushroom_2.json",
	},
]
const OUTSIDE3_SECOND_END: String = "res://dialog/dialogueMrBlob/end_dialog_outside3_blob.json"

const SPACESHIPROOM_FLOW := [
	{
		"flag":"",
		"path":"",
	},
]
const SPACESHIPROOM_FLOW_END: String = "res://dialog/dialogueMrBlob/end_dialog_outside3_blob.json"

func _ready() -> void:
	super._ready()

# Szene → Dialogdatei
func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside1":
		return _get_outside1_dialog()

	elif scene_name == "Outside2":
		var has_item: bool = hotbarglobal.has_item(required_item_id)
		var unlocked: bool = bool(GameState.puzzle_state.get(OUTSIDE2_SECOND_UNLOCK_FLAG, false))

		if has_item and unlocked:
			return _get_outside2_second_dialog()

		if has_item and not unlocked:
			return OUTSIDE2_LOCKED_WITH_ITEM_DIALOG

		return _get_outside2_dialog()

	elif scene_name == "Outside3":
		if GameState.puzzle_state.has("stone_puzzle"):
			return _get_outside3_second_dialog()
		return _get_outside3_dialog()
		
	elif scene_name == "Spaceship_room":
		return _get_spaceship_room_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_outside1_dialog() -> String:
	for step in OUTSIDE1_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE1_END

func _get_outside2_dialog() -> String:
	for step in OUTSIDE2_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE2_END

func _get_outside2_second_dialog() -> String:
	for step in OUTSIDE2_SECOND_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE2_SECOND_END

func _get_outside3_dialog() -> String:
	for step in OUTSIDE3_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE3_FLOW[-1]["path"]

func _get_outside3_second_dialog() -> String:
	for step in OUTSIDE3_SECOND_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE3_SECOND_END

func _physics_process(delta: float) -> void:
	if fleeing:
		var dir = (flee_target - global_position)
		if dir.length() < 8.0:
			fleeing = false
			# FINAL-Position speichern, damit nach Neustart genau dort steht
			GameState.puzzle_state["npc_pos_" + npc_id] = {
				"x": global_position.x,
				"y": global_position.y,
			}
			return
		velocity = dir.normalized() * move_speed 
		move_and_slide()

func run_away_to(pos: Vector2) -> void:
	fleeing = true
	flee_target = pos
	#return OUTSIDE3_END
	
func _get_spaceship_room_dialog() -> String:
	for step in SPACESHIPROOM_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return SPACESHIPROOM_FLOW_END
