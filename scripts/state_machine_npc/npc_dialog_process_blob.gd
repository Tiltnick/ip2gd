extends NPC
class_name NpcDialogProcessBlob

var cutscene_locked := false
var fleeing := false
var flee_target := Vector2.ZERO
var npc_id: String = "blob"
var required_item_id: String = "shovel"
@export var spawn_marker: Marker2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

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

const OUTSIDE1_SECOND_FLOW := [
	{
		"flag": "outside1_endscene_done",
		"path": "res://dialog/dialogueMrBlob/outside_1_flower.json",
	}
]
const OUTSIDE1_SECOND_END: String = ""

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

const OUTSIDE4_FLOW := [
	{
		"flag": "blob_flower_done",
		"path": "res://dialog/dialogueMrBlob/outside_4.json",
	}
]
const OUTSIDE4_FLOW_END: String = ""


const SPACESHIPROOM_FLOW := [
	{
		"flag":"",
		"path":"",
	},
]
const SPACESHIPROOM_FLOW_END: String = "res://dialog/dialogueMrBlob/end_dialog_outside3_blob.json"

func _ready() -> void:
	super._ready()

	var npc_pos = "npc_pos_" + npc_id

	if GameState.puzzle_state.has(npc_pos):
		var d = GameState.puzzle_state[npc_pos]
		if typeof(d) == TYPE_DICTIONARY and d.has("x") and d.has("y"):
			global_position = Vector2(d["x"], d["y"])
	elif spawn_marker:
		global_position = spawn_marker.global_position


	DialogManager.dialog_finished.connect(_on_dialog_finished)


# Szene → Dialogdatei
func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside1":
		if GameState.puzzle_state.has("outside5_pillar_puzzle_solved"):
			return _get_outside1_second_dialog()
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
	
	elif scene_name == "Outside4":
		return _get_outside4_dialog()
		
	elif scene_name == "Spaceship_room":
		return _get_spaceship_room_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_outside1_dialog() -> String:
	for step in OUTSIDE1_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE1_END
	
func _get_outside1_second_dialog() -> String:
	for step in OUTSIDE1_SECOND_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE1_SECOND_END

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

func _get_outside4_dialog() -> String:
	for step in OUTSIDE4_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return OUTSIDE4_FLOW_END

func _get_spaceship_room_dialog() -> String:
	for step in SPACESHIPROOM_FLOW:
		if not bool(GameState.puzzle_state.get(step["flag"], false)):
			return step["path"]
	return SPACESHIPROOM_FLOW_END

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

signal walk_away_done

func walk_away() -> void:
	cutscene_locked = true
	velocity = Vector2.ZERO
	move_and_slide()

	var path := ""
	if get_tree().current_scene:
		path = get_tree().current_scene.scene_file_path

	if path == "res://scenes/maps/Outside_4/Outside_4.tscn":
		animation_player.play("walk_away_outside_4")
	elif path == "res://scenes/maps/Outside_1/Outside_1.tscn":
		animation_player.play("walk_away_outside_1")

	await animation_player.animation_finished
	walk_away_done.emit()
	queue_free()

func _on_dialog_finished() -> void:
#	var scene_name := get_tree().current_scene.name

	if last_dialog_path == "res://dialog/dialogueMrBlob/outside_1.json":
		QuestManager.add_quest("quest_4")
		
	elif last_dialog_path == "res://dialog/dialogueMrBlob/outside_1_end.json":
		walk_away()
	
	elif last_dialog_path == "res://dialog/dialogueMrBlob/outside_4.json":
		if GameState.picked_items.has("flower"):
			GameState.picked_items.erase("flower")
