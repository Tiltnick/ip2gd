extends ZoomStoreItem
class_name FlashlightItem

func _ready() -> void:
	save_id = "flashlight_1"
	hotbar_id = "flashlight"

	item_name_de = "Taschenlampe"
	item_name_en = "Flashlight"

	super._ready()
	

func interact() -> void:
	super.interact()
	if not GameState.puzzle_state.get(save_id, false):
		DialogManager.start_dialog(
			"res://dialog/innerMonologue/discovering_flashlight.json"
		)
