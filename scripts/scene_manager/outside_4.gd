extends Node2D
const blob: PackedScene = preload("res://scenes/Character/npc.tscn")
@onready var blob_spawn: Marker2D = $SpawnPoints/blob

func _ready() -> void:
	BgmPlayer.bgm_outside4()
	if GameState.puzzle_state.has("outside5_pillar_puzzle_solved"):
		var blob_instance = blob.instantiate()
		blob_instance.global_position = blob_spawn.global_position
		add_child(blob_instance)


func configure_camera(cam: Camera2D) -> void:
	# Cam Limits
	cam.limit_left = -449
	cam.limit_right = 432
	cam.limit_top = -289
	cam.limit_bottom = 254
