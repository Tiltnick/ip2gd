extends CharacterBody2D
class_name NPC

@export var move_speed: float = 50.0
@export var detect_radius: float = 120.0

# Path zuweisen
@export var path_follow: PathFollow2D

@onready var anim: AnimatedSprite2D = $anim
@onready var outline: AnimatedSprite2D = $Outline
@onready var detect_area: Area2D = $DetectionArea
@onready var e_popup_node: Control = $Press_E_Popup_NPC

var player_inside := false
var player: Node2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	outline.visible = false

	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	outline.visible = player_inside

	if player_inside:
		outline.frame = anim.frame


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true
		outline.visible = true
		if e_popup_node:
			e_popup_node.visible = true
			# Das reicht um einen Dialog zu starten :) 
			DialogManager.start_dialog("res://dialog/oris_mr_blob.json")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		DialogManager.hide()
		player_inside = false
		outline.visible = false
		if e_popup_node:
			e_popup_node.visible = false
