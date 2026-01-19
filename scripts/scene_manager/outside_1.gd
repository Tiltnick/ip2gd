extends Node2D
@onready var blob_spawn: Marker2D = $SpawnPoints/Marker2D
@onready var old_blob: NpcDialogProcessBlob = $NPC
const blob: PackedScene = preload("res://scenes/Character/npc.tscn")

func _ready() -> void:
	BgmPlayer.bgm_outside1()
	# Einmaliger innerer Monolog direkt nach dem Verlassen des Raumschiffs
	if GameState.puzzle_state.get("ship_exit_monologue_pending", false):
		# Flag sofort verbr, damit es nur einmal passiert
		GameState.puzzle_state["ship_exit_monologue_pending"] = false

		DialogManager.start_dialog("res://dialog/innerMonologue/exiting_spaceship.json")
		await DialogManager.dialog_finished
		QuestManager.complete_quest("quest1")

	if GameState.puzzle_state.has("outside5_pillar_puzzle_solved"):
		var blob_instance = blob.instantiate()
		blob_instance.global_position = blob_spawn.global_position
		add_child(blob_instance)
		old_blob.hide()


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -440
	cam.limit_right = 425
	cam.limit_top = -285
	cam.limit_bottom = 270
