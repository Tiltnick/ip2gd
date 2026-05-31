extends Node2D

const BLOB_SCENE: PackedScene = preload("res://scenes/Character/npc.tscn")
const BLOB_RAN_AWAY_OUTSIDE1_FLAG := "blob_ran_away_outside1"


@onready var blob_spawn: Marker2D = $SpawnPoints/blob_outside4
@onready var old_blob: NpcDialogProcessBlob = $NPC
@onready var funghi: NPC = $NPC_funghi_shmunghi
@onready var shmunghi: NPC = $NPC_funghi_shmunghi2

var blob: NpcDialogProcessBlob = null

func _ready() -> void:
	GameState.unlock_progress_key("outside_1_entered")
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
	cam.limit_left = -445
	cam.limit_right = 425
	cam.limit_top = -285
	cam.limit_bottom = 270
