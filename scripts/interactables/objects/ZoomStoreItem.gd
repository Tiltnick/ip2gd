extends SaveableItem
class_name ZoomStoreItem

@export var hotbar_id: String = ""
@export var hotbar_scale: Vector2 = Vector2(0.5, 0.5)

var is_zoomed := false
var start_scale: Vector2

func _ready() -> void:
	start_scale = scale
	super._ready()

func interact() -> void:
	SfxPlayer.ui_click_sound()

	if not is_zoomed and hotbar_id not in ["telescope", "fluxomat"]:
		_zoom_in()
	else:
		_store_in_hotbar()



func _zoom_in():
	z_index= 100
	is_zoomed = true
	outline.visible = false
	outline_locked = true

	if e_popup_node:
		e_popup_node.visible = false
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center
	var t := create_tween()
	t.tween_property(self, "scale", start_scale * 7, 0.2)

func _store_in_hotbar():
	if spawned_from_hotbar:
		queue_free()
		return
	z_index = 0
	mark_collected()

	if hotbar_id != "":
		hotbarglobal.add_item(hotbar_id)

	if hotbar_id not in ["telescope", "fluxomat"]:
		queue_free()

func hotbar_activate():
	spawned_from_hotbar = true

	is_zoomed = false
	outline.visible = false
	outline_locked = true


	# items zoomen aus hotbar raus in die mitte des screens, nicht mehr abgängig von der player position 
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center


	#var cam := get_viewport().get_camera_2d()
	#global_position = cam.global_position if cam else Vector2.ZERO

	scale = hotbar_scale
	start_scale = scale
	z_index = 100

	_zoom_in()
