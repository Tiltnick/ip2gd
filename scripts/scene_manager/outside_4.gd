extends Node2D

const BLOB_SCENE: PackedScene = preload("res://scenes/Character/npc.tscn")

@onready var blob_spawn: Marker2D = $SpawnPoints/blob
@onready var cutscene_cam: Camera2D = $CutsceneCamera

var blob_instance: Node = null
var follow_blob := false


func _ready() -> void:
	BgmPlayer.bgm_outside4()
#	QuestManager.add_quest("quest_11")

	if not DialogManager.dialog_finished.is_connected(_on_dialog_finished):
		DialogManager.dialog_finished.connect(_on_dialog_finished)

	if GameState.picked_items.has("flower"):
		blob_instance = BLOB_SCENE.instantiate()
		blob_instance.global_position = blob_spawn.global_position
		add_child(blob_instance)

func configure_camera(cam: Camera2D) -> void:
	cam.limit_left = -449
	cam.limit_right = 432
	cam.limit_top = -289
	cam.limit_bottom = 254


func _process(_delta: float) -> void:
	if follow_blob and is_instance_valid(blob_instance) and cutscene_cam.is_current():
		cutscene_cam.global_position = blob_instance.global_position
	else:
		set_process(false)


func _on_dialog_finished() -> void:
	if not is_instance_valid(blob_instance):
		return

	#if blob_instance.has_signal("walk_away_done"):
		#if not blob_instance.walk_away_done.is_connected(_on_blob_walk_away_done):
			#blob_instance.walk_away_done.connect(_on_blob_walk_away_done, CONNECT_ONE_SHOT)
#
		#blob_instance.walk_away()
	#else:
		#blob_instance.walk_away()
		#await get_tree().create_timer(2.0).timeout
		#_on_blob_walk_away_done()
#
#
#func _on_blob_walk_away_done() -> void:
	#follow_blob = false
	#set_process(false)
