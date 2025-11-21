extends Node2D

@export_file("*.tscn")
var player_scene_path: String = "res://scenes/Character/main_character.tscn"

@onready var spawn_points: Node = $SpawnPoints

func _ready() -> void:
	spawn_player()


func spawn_player() -> void:
	var packed: PackedScene = load(player_scene_path)
	var player: Node2D = packed.instantiate()

	# Spawnpoint anhand des Namens aus dem SceneManager holen
	var spawn: Node2D = spawn_points.get_node_or_null(SceneManager.next_spawn_id)
	if spawn == null:
		spawn = spawn_points.get_node("start")

	player.global_position = spawn.global_position
	add_child(player)
