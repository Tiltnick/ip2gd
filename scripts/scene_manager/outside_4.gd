extends Node2D

const BLOB_SCENE: PackedScene = preload("res://scenes/Character/npc.tscn")

@onready var blob_spawn: Marker2D = $SpawnPoints/blob
@onready var cutscene_cam: Camera2D = $CutsceneCamera

var blob_instance: Node = null
var follow_blob := false


func _ready() -> void:
	GameState.unlock_progress_key("outside_4_entered")
	BgmPlayer.bgm_outside4()
#	QuestManager.add_quest("quest_11")

	if not DialogManager.dialog_finished.is_connected(_on_dialog_finished):
		DialogManager.dialog_finished.connect(_on_dialog_finished)

	if GameState.picked_items.has("flower"):
		blob_instance = BLOB_SCENE.instantiate()
		add_child(blob_instance)
		blob_instance.global_position = blob_spawn.global_position
		blob_instance.move_speed = 200

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
