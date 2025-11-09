extends "res://scripts/interactable_object.gd"

@onready var front: Sprite2D = $Sprite_Front
@onready var back: Sprite2D = $Sprite_Back

var is_front := true
var is_zoomed := false
var front_start_scale: Vector2
var back_start_scale: Vector2
var photo_active := false   
var node_start_scale = scale

func _ready():
	front_start_scale = front.scale
	back_start_scale = back.scale
	
func _process(delta):
	if (outline.visible or photo_active) and Input.is_action_just_pressed("interact"):
		_on_interact()


func _on_interact():
	if not is_zoomed:
		is_zoomed = true
		photo_active = true
		_hide_outline()
		_zoom_in()
	elif is_zoomed and is_front:
		_flip_photo()
		_hide_outline()
	else:
		_reset_photo()

func _zoom_in():
	var tween = create_tween()
	tween.tween_property(self, "scale", node_start_scale * 2, 0.2)
	
func _flip_photo():
	_hide_outline()
	var tween = create_tween()
	tween.tween_property(front, "scale:x", 0, 0.15)
	tween.tween_callback(Callable(self, "_toggle_sides"))
	tween.tween_property(front, "scale:x", front_start_scale.x, 0.15)




func _toggle_sides():
	is_front = !is_front
	front.visible = is_front
	back.visible = !is_front

func _reset_photo():
	var tween = create_tween()
	tween.tween_property(self, "scale", node_start_scale, 0.2)
	tween.tween_callback(Callable(self, "_reset_state"))

func _reset_state():
	is_zoomed = false
	photo_active = false
	is_front = true
	front.visible = true
	back.visible = false
	_show_outline() 


func _show_outline():
	if photo_active:
		outline.visible = false
	else:
		if get_node("Area2D").has_overlapping_bodies():
			outline.visible = true


func _hide_outline():
	outline.visible = false
