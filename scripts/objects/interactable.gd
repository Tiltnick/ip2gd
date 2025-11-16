extends Node2D
class_name Interactable

@onready var outline := $Outline
@onready var area := $Area2D

var player_in_area := false
var outline_locked := false

var e_popup  # UI-Anzeige für "E"

func _ready():
	outline.visible = false
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

	# E-Icon laden
	var popup_scene = load("res://scenes/Menues/Press_E.tscn")
	e_popup = popup_scene.instantiate()
	add_child(e_popup)
	e_popup.visible = false
	# optional: Popup über Objekt platzieren
	e_popup.position = Vector2(0, -20)

func _on_enter(body):
	if body.is_in_group("player"):
		player_in_area = true
		if not outline_locked:
			outline.visible = true
		e_popup.visible = true

func _on_exit(body):
	if body.is_in_group("player"):
		player_in_area = false
		outline.visible = false
		e_popup.visible = false

func interact():
	print(name, " interacted but has no special interact() function!")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		interact()
