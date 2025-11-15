extends CharacterBody2D
class_name NPC

# Player festlegen
@export var player_path: NodePath
@export var detect_radius: float = 120.0
@export var move_speed: float = 50.0

@onready var anim: AnimatedSprite2D = $anim

var player: Node2D

# Player init
func _ready() -> void:
	if player_path != NodePath():
		player = get_node(player_path)

# Funktion zu checken ob der Spieler existiert und Abstand checken
func is_player_near() -> bool:
	if not is_instance_valid(player):
		return false
	return global_position.distance_to(player.global_position) <= detect_radius
