extends SaveableItem

func _ready() -> void:
	save_id = "phone"
	item_name_de = "Handy"
	item_name_en = "Phone"

	super._ready()


func interact() -> void:
	SfxPlayer.ui_click_sound()

	if GameState.puzzle_state.get(save_id, false):
		return

	mark_collected()

	PhoneButton.update_visibility()

	queue_free()
