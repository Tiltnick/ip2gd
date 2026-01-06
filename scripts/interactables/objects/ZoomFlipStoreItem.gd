extends ZoomStoreItem
class_name ZoomFlipStoreItem

@export var auto_flip_on_pickup := true
@export var flip_delay_seconds := 0.5   # Zeit bis Flip
@export var back_side_seconds := 0.8     # wie lange Rückseite gezeigt wird

var is_front := true

var _flip_timer: SceneTreeTimer = null
var _back_timer: SceneTreeTimer = null

func interact() -> void:
	SfxPlayer.ui_click_sound()

	# Bereits gezoomt dann manuelles Durchklicken
	if is_zoomed:
		_cancel_all_timers()

		if is_front:
			_flip()
		else:
			_store_in_hotbar()
		return

	# Erstes Interact dann Zoom
	_zoom_in()

	# Automatik nur beim Pickup
	if not spawned_from_hotbar and auto_flip_on_pickup:
		_schedule_flip_after_zoom()



func _schedule_flip_after_zoom() -> void:
	_cancel_flip_timer()
	_flip_timer = get_tree().create_timer(flip_delay_seconds)
	_flip_timer.timeout.connect(func():
		if is_zoomed and is_front and not spawned_from_hotbar:
			_flip()
			_start_back_side_timer()
	)

func _start_back_side_timer() -> void:
	_cancel_back_timer()
	_back_timer = get_tree().create_timer(back_side_seconds)
	_back_timer.timeout.connect(func():
		if is_zoomed and not is_front and not spawned_from_hotbar:
			_store_in_hotbar()
	)


func _cancel_flip_timer() -> void:
	_flip_timer = null

func _cancel_back_timer() -> void:
	_back_timer = null

func _cancel_all_timers() -> void:
	_cancel_flip_timer()
	_cancel_back_timer()
	_cancel_auto_store() 

func _store_in_hotbar() -> void:
	_cancel_all_timers()
	super._store_in_hotbar()



func _flip() -> void:
	push_warning("ZoomFlipStoreItem: _flip() not implemented in child.")
