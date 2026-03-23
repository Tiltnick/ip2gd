extends Node2D

const BLOB_SCENE: PackedScene = preload("res://scenes/Character/npc.tscn")
const BLOB_RAN_AWAY_OUTSIDE1_FLAG := "blob_ran_away_outside1"


@onready var blob_spawn: Marker2D = $SpawnPoints/blob_outside4
@onready var old_blob: NpcDialogProcessBlob = $NPC
@onready var funghi: NPC = $NPC_funghi_shmunghi
@onready var shmunghi: NPC = $NPC_funghi_shmunghi2

var blob: NpcDialogProcessBlob = null

func _ready() -> void:
	BgmPlayer.bgm_outside1()
	
	if GameState.puzzle_state.get(BLOB_RAN_AWAY_OUTSIDE1_FLAG, false):
		if is_instance_valid(old_blob):
			old_blob.queue_free()
		if is_instance_valid(funghi):
			funghi.queue_free()
		if is_instance_valid(shmunghi):
			shmunghi.queue_free()
		return 
		
	# Einmaliger innerer Monolog
	if GameState.puzzle_state.get("ship_exit_monologue_pending", false):
		GameState.puzzle_state["ship_exit_monologue_pending"] = false
		DialogManager.start_dialog("res://dialog/innerMonologue/exiting_spaceship.json")
		await DialogManager.dialog_finished
		QuestManager.complete_quest("quest_1")

	# Blob spawnen / ersetzen
	if GameState.puzzle_state.has("outside5_pillar_puzzle_solved"):
		blob = BLOB_SCENE.instantiate() as NpcDialogProcessBlob
		add_child(blob)
		blob.call_deferred("set_global_position", blob_spawn.global_position)
		blob.move_speed = 200
		old_blob.hide()
		funghi.queue_free()
		shmunghi.queue_free()
	else:
		blob = old_blob

		
func configure_camera(cam: Camera2D) -> void:
	cam.limit_left = -448
	cam.limit_right = 431
	cam.limit_top = -309
	cam.limit_bottom = 272
	_write_map_bounds(cam)

func _write_map_bounds(cam: Camera2D) -> void:
	const PATH := "user://analytics/map_bounds.json"
	var all_bounds: Dictionary = {}
	if FileAccess.file_exists(PATH):
		var f := FileAccess.open(PATH, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				all_bounds = parsed
	all_bounds[scene_file_path] = {
		"limit_left": cam.limit_left,
		"limit_right": cam.limit_right,
		"limit_top": cam.limit_top,
		"limit_bottom": cam.limit_bottom,
	}
	var f2 := FileAccess.open(PATH, FileAccess.WRITE)
	if f2:
		f2.store_string(JSON.stringify(all_bounds))
