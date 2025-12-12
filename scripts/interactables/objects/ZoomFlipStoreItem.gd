extends ZoomStoreItem
class_name ZoomFlipStoreItem

var is_front := true

func interact() -> void:
	WorldAudioManager.play_sfx(load("res://assets/sound/sfx/ButtonClick.wav"))

	if not is_zoomed:
		_zoom_in()
	elif is_front:
		_flip()
	else:
		_store_in_hotbar()


func _flip() -> void:
	push_warning("ZoomFlipStoreItem: _flip() not implemented in child.")
