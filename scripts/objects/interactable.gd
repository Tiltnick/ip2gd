extends Node2D
class_name Interactable

# Nodes
@onready var outline := $Outline
@onready var area := $Area2D
@export var e_popup_path: NodePath
var e_popup: Control

# State
var player_in_area := false
var outline_locked := false

func _ready():
	# Outline initial unsichtbar
	outline.visible = false

	# Area2D Signale verbinden
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

	# E-Popup Referenz holen, falls gesetzt
	if e_popup_path != null:
		e_popup = get_node(e_popup_path)
		if e_popup:
			e_popup.visible = false
			# Position relativ zum Objekt, z.B. über dem Mittelpunkt
			e_popup.position = Vector2(-10, -55)
			

func _on_enter(body):
	if body.is_in_group("player"):
		print("Player entered Diary Area")
		player_in_area = true
		if not outline_locked:
			outline.visible = true
		if e_popup:
			e_popup.visible = true

func _on_exit(body):
	if body.is_in_group("player"):
		player_in_area = false
		outline.visible = false
		if e_popup:
			e_popup.visible = false

# Kann von speziellen Objekten überschrieben werden
func interact():
	print(name, " interacted but has no special interact() function!")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		interact()
