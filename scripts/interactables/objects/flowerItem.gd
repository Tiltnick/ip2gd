extends ZoomStoreItem
class_name FlowerItem

@export var collect_dialog_path: String = "res://dialog/innerMonologue/picking_up_flower.json"
@export var collect_dialog_flag: String = "outside5_flower_collect_dialog_done"
@export var sam_gone_flag: String = "outside5_sam_gone"

func _store_in_hotbar() -> void:
	
	var from_world := (not spawned_from_hotbar)

	if from_world:
		
		GameState.puzzle_state[sam_gone_flag] = true
		_disable_sam_now()

	
		if collect_dialog_path != "" and not GameState.puzzle_state.get(collect_dialog_flag, false):
			GameState.puzzle_state[collect_dialog_flag] = true
			DialogManager.start_dialog(collect_dialog_path)

	
	super._store_in_hotbar()
	
	QuestManager.complete_quest("quest10")


func _disable_sam_now() -> void:
	print("SAMS FOUND:", get_tree().get_nodes_in_group("sam_state_machine").size())

	
	var sams := get_tree().get_nodes_in_group("sam_state_machine")
	for sam in sams:
		if is_instance_valid(sam) and sam.has_method("disable_sam"):
			sam.disable_sam()
