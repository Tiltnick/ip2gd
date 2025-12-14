extends Node2D
class_name Interactable

@onready var outline: Node2D = get_node_or_null("Outline")
@onready var area: Area2D = $Area2D

@export var e_popup_node: Node
var player_in_area := false
var outline_locked := false

func _ready():
	if outline:
		outline.visible = false

	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _on_enter(body):
	if body.is_in_group("player"):
		player_in_area = true
		if outline and not outline_locked:
			outline.visible = true
		if e_popup_node:
			e_popup_node.visible = true

func _on_exit(body):
	if body.is_in_group("player"):
		player_in_area = false
		if outline:
			outline.visible = false
		if e_popup_node:
			e_popup_node.visible = false

func interact():
	pass
	

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		interact()
