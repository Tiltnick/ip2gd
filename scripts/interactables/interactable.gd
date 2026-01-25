extends Node2D
class_name Interactable

@onready var outline: Node2D = get_node_or_null("Outline")
@onready var area: Area2D = $Area2D

@export var e_popup_node: Node

@export var disable_area_on_interact: bool = true

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
	if Input.is_action_just_pressed("interact"):
		var allow := player_in_area

		# wenn das Objekt is_zoomed hat und gerade gezoomt ist
		if not allow:
			for p in get_property_list():
				if p.name == "is_zoomed":
					allow = bool(get("is_zoomed"))
					break

		if allow:
			_hide_interact_ui()
			interact()



func _hide_interact_ui() -> void:

	if outline:
		outline.visible = false
	if e_popup_node:
		e_popup_node.visible = false

	if disable_area_on_interact:
		player_in_area = false
		if area:
			area.set_deferred("monitoring", false)
