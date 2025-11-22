extends Interactable

@onready var front := $Sprite_Front
@onready var back := $Sprite_Back

var is_front := true
var is_zoomed := false

var start_scale: Vector2
var front_start_scale: Vector2
var back_start_scale: Vector2

func _ready():
	front_start_scale = front.scale
	back_start_scale = back.scale
	start_scale = scale
	super._ready()


func interact():
	if not is_zoomed:
		_zoom_in()
	elif is_front:
		_flip_photo()
	else:
		_store_in_hotbar()

func _store_in_hotbar():
	hotbarglobal.add_item("photo")
	queue_free()


func _zoom_in():
	is_zoomed = true
	outline.visible = false
	outline_locked = true
	
	if e_popup_node: 
		e_popup_node.visible = false
	


	var t = create_tween()
	t.tween_property(self, "scale", start_scale * 7, 0.2)


func _flip_photo():
	_disable_outline_full()

	var tween = create_tween()
	tween.tween_property(front, "scale:x", 0, 0.15)
	tween.tween_callback(Callable(self, "_toggle_sides"))
	tween.tween_property(front, "scale:x", front_start_scale.x, 0.15)


func _toggle_sides():
	is_front = !is_front
	front.visible = is_front
	back.visible = !is_front


func _reset_photo():
	var t = create_tween()
	t.tween_property(self, "scale", start_scale, 0.2)
	t.tween_callback(Callable(self, "_reset_state"))


func _reset_state():
	is_zoomed = false
	is_front = true
	front.visible = true
	back.visible = false

	outline_locked = false
	_try_show_outline()
	
	if e_popup_node and player_in_area:
		e_popup_node.visible = true


func _disable_outline_full():
	outline.visible = false
	outline_locked = true


func _try_show_outline():
	if outline_locked:
		outline.visible = false
		return
	outline.visible = true
