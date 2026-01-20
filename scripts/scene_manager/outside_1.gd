extends Node2D

const BLOB_SCENE: PackedScene = preload("res://scenes/Character/npc.tscn")

@onready var blob_spawn: Marker2D = $SpawnPoints/blob_outside4
@onready var old_blob: NpcDialogProcessBlob = $NPC

var blob: NpcDialogProcessBlob = null

func _ready() -> void:
	BgmPlayer.bgm_outside1()
	
	# Einmaliger innerer Monolog
	if GameState.puzzle_state.get("ship_exit_monologue_pending", false):
		GameState.puzzle_state["ship_exit_monologue_pending"] = false
		DialogManager.start_dialog("res://dialog/innerMonologue/exiting_spaceship.json")
		await DialogManager.dialog_finished
		QuestManager.complete_quest("quest_1")

	# Blob spawnen / ersetzen
	if GameState.puzzle_state.has("outside5_pillar_puzzle_solved"):
		blob = BLOB_SCENE.instantiate() as NpcDialogProcessBlob
		blob.global_position = blob_spawn.global_position
		add_child(blob)
		old_blob.hide()
	else:
		blob = old_blob
		
	if GameState.dialog_state.has("res://dialog/dialogueMrBlob/outside_1_end.json"):
		blob.walk_away()
		
func configure_camera(cam: Camera2D) -> void:
	cam.limit_left = -440
	cam.limit_right = 425
	cam.limit_top = -285
	cam.limit_bottom = 270
