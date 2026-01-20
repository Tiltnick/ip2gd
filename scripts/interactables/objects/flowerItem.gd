extends ZoomStoreItem
class_name FlowerItem

@export var collect_dialog_path: String = "res://dialog/innerMonologue/picking_up_flower.json"
@export var collect_dialog_flag: String = "outside5_flower_collect_dialog_done"

func _store_in_hotbar() -> void:
	# Schutz vor Doppelsammeln
	if save_id != "" and GameState.puzzle_state.get(save_id, false) and not spawned_from_hotbar:
		return

	# Standard-Verhalten aus ZoomStoreItem
	super._store_in_hotbar()

	if not spawned_from_hotbar:
		if collect_dialog_path != "" and not GameState.puzzle_state.get(collect_dialog_flag, false):
			GameState.puzzle_state[collect_dialog_flag] = true
			DialogManager.start_dialog(collect_dialog_path)
