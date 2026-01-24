extends SaveableItem
class_name ZoomStoreItem

@export var hotbar_id: String = ""
@export var hotbar_scale: Vector2 = Vector2(0.5, 0.5)


@export var auto_store_on_pickup := true
@export var auto_store_seconds := 0.8

var _auto_store_timer: SceneTreeTimer = null


var is_zoomed := false
var start_scale: Vector2

func _ready() -> void:
	start_scale = scale
	super._ready()

func interact() -> void:
	SfxPlayer.ui_click_sound()

	#wenn items gezzoomt dann kann man sie ncoh mit e weglegen
	if is_zoomed:
		_cancel_auto_store()
		_store_in_hotbar()
		return

	# beim ersten e zoomen
	if hotbar_id not in ["telescope", "fluxomat"]:
		_zoom_in()

		# timer nur beim einsammeln von item
		if auto_store_on_pickup and not spawned_from_hotbar:
			_start_auto_store()
	else:
		# bei items die nicht zoomen sollen bleibt store direkte aktion
		_store_in_hotbar()


func _start_auto_store() -> void:
	_cancel_auto_store()
	_auto_store_timer = get_tree().create_timer(auto_store_seconds)
	_auto_store_timer.timeout.connect(func():
		# wenn noch oiffen und nicht aus hotbar angesprochen
		if is_zoomed and not spawned_from_hotbar:
			_store_in_hotbar()
	)

func _cancel_auto_store() -> void:
	# den timer auf null setzen
	_auto_store_timer = null


func _zoom_in():
	z_index= 100
	is_zoomed = true
	outline.visible = false
	outline_locked = true

	if e_popup_node:
		e_popup_node.visible = false

	# items in mitte des screens zoomen
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center

	
	var t := create_tween()
	t.tween_property(self, "scale", start_scale * 7, 0.2)

func _store_in_hotbar():
	
	_cancel_auto_store()
	
	# schon eingesammelt, dann mach nichts mehr, kein popup oder add_item
	if save_id != "" and GameState.puzzle_state.get(save_id, false) and not spawned_from_hotbar:
		return
	
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
	if hotbar_id == "map":
		MiniMap.open() # oder open()
		queue_free() 
		print("map funktd")    # damit das Item nicht im Level rumliegt
		return
	spawned_from_hotbar = true

	is_zoomed = false
	outline.visible = false
	outline_locked = true


	# items zoomen aus hotbar raus in die mitte des screens, nicht mehr abgängig von der player position 
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center


	scale = hotbar_scale
	start_scale = scale
	z_index = 100

	_zoom_in()
	
	
