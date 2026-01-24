extends NPC
class_name NpcDialogProcessTruffle

var fleeing := false
var flee_target := Vector2.ZERO
@export var npc_id: String = "truffle"
# Szene → Dialogdatei
const DIALOG_BY_SCENE := {
	"Outside3": "res://dialog/mushrooms/truffle.json",
}

# Reihenfolge wichtig
const OUTSIDE3_FLOW := [
	{
		"flag": "mushroom_dialog_done",
		"path": "res://dialog/mushrooms/begin_truffle.json",
	},
]
const OUTSIDE3_SECOND_FLOW := [
	{
		"flag": "truffle_dialog_done",
		"path": "res://dialog/mushrooms/truffle_2.json",
	},
]
const OUTSIDE3_END := "res://dialog/mushrooms/truffle.json"
const DEFAULT_DIALOG := "Kein Dialog gefunden"

func _ready() -> void:
	super._ready()
	
	var npc_pos = "npc_pos_" + npc_id
	#proving if position saved in game state right
	if GameState.puzzle_state.has(npc_pos):
		var d = GameState.puzzle_state[npc_pos]
		if typeof(d) == TYPE_DICTIONARY and d.has("x") and d.has("y"):
			global_position = Vector2(d["x"], d["y"])


func get_dialog_path(scene_name: String) -> String:
	if scene_name == "Outside3":
		if GameState.puzzle_state.has("mushroom_riddle_solved_dialog_shown"):
			return _get_outside3_second_dialog()
		return _get_outside3_dialog()

	return DIALOG_BY_SCENE.get(scene_name, DEFAULT_DIALOG)

func _get_outside3_dialog() -> String:
	for step in OUTSIDE3_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step["path"]
	return OUTSIDE3_END

func _get_outside3_second_dialog() -> String:
	for step in OUTSIDE3_SECOND_FLOW:
		if not GameState.puzzle_state.get(step["flag"], false):
			return step ["path"]
	return OUTSIDE3_SECOND_FLOW[-1]["path"]

func _physics_process(delta: float) -> void:
	if fleeing:
		var dir = (flee_target - global_position)
		if dir.length() < 8.0:
			fleeing = false
			# save position
			GameState.puzzle_state["npc_pos_" + npc_id] = {
				"x": global_position.x,
				"y": global_position.y,
			}

			dialog_active = false 
			return

		velocity = dir.normalized() * move_speed * 3.0
		move_and_slide()


func run_away_to(pos: Vector2) -> void:
	fleeing = true
	flee_target = pos
	move_and_slide()
