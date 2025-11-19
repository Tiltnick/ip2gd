extends Node2D
class_name Interactable

# Nodes
@onready var outline := $Outline
@onready var area := $Area2D

# Statt Child: NodePath oder direkt Node setzen
@export var e_popup_node: Node  # z.B. auf "UI_Popups/Press_E_Popup_Foto" setzen
var player_in_area := false
var outline_locked := false

func _ready():
	outline.visible = false
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _on_enter(body):
	if body.is_in_group("player"):
		player_in_area = true
		if not outline_locked:
			outline.visible = true
		if e_popup_node:
			e_popup_node.visible = true

func _on_exit(body):
	if body.is_in_group("player"):
		player_in_area = false
		outline.visible = false
		if e_popup_node:
			e_popup_node.visible = false

func interact():
	print(name, " interacted but has no special interact() function!")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		interact()
