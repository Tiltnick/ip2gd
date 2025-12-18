extends SaveableItem
class_name HotbarCollectZoomItem

@export var hotbar_id: String = ""
@export var hotbar_scale: Vector2 = Vector2(0.5, 0.5)
@export var zoom_factor: float = 7.0
@export var zoom_time: float = 0.2

var is_zoomed := false
var start_scale: Vector2

func _ready() -> void:
	start_scale = scale
	super._ready()


func interact() -> void:
	SfxPlayer.ui_click_sound()

	# einsammeln -> in hotbar & inventory -> weg
	if not spawned_from_hotbar:
		_collect_into_hotbar_and_inventory()
		return

	# toggle zoom (rein/raus)
	if not is_zoomed:
		_zoom_in()
	else:
		_close_from_hotbar()


func _collect_into_hotbar_and_inventory() -> void:
	# schon eingesammelt -> nix tun
	if save_id != "" and GameState.puzzle_state.get(save_id, false):
		return

	# speichert + popup aus SaveableItem
	mark_collected()

	# in hotbar/inventory
	if hotbar_id != "":
		hotbarglobal.add_item(hotbar_id)

	# world item weg
	queue_free()


func hotbar_activate() -> void:
	# wird von hotbar.gd nach dem Spawn aufgerufen
	spawned_from_hotbar = true
	is_zoomed = false

	scale = hotbar_scale
	start_scale = scale
	z_index = 100

	_zoom_in()


func _zoom_in() -> void:
	is_zoomed = true
	z_index = 100

	# opt e-popup aus
	if e_popup_node:
		e_popup_node.visible = false

	# in Screenmitte setzen
	var vp := get_viewport()
	var screen_center := vp.get_visible_rect().size * 0.5
	global_position = vp.get_canvas_transform().affine_inverse() * screen_center

	var t := create_tween()
	t.tween_property(self, "scale", start_scale * zoom_factor, zoom_time)


func _close_from_hotbar() -> void:
	# Hotbar-Instanz soll  verschwinden
	queue_free()
