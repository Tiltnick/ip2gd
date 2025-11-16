extends Node2D
class_name Interactable

@onready var outline := $Outline
@onready var area := $Area2D

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

func _on_exit(body):
	if body.is_in_group("player"):
		player_in_area = false
		outline.visible = false

func interact():
	# default fallback – darf überschrieben werden!
	print(name, " interacted but has no special interact() function!")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		interact()
