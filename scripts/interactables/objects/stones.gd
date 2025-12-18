extends Interactable

@export var save_id: String = ""
@export var item_path: NodePath
var item: ZoomStoreItem 

func _ready():
	super._ready()
	
	if item_path != NodePath("") and is_in_group("stones"):
		item = get_node(item_path) as ZoomStoreItem

#	else:
#		push_warning("Kein Code-Popup Pfad gesetzt!")

	if GameState.puzzle_state.get(save_id, false):
		queue_free()


func interact() -> void:
	if is_in_group("stones"):
		if hotbarglobal.inventory_items.has("shovel"):
			GameState.puzzle_state[save_id] = true
			#item.visible = true
			remove_stones()
		else:
			DialogManager.start_dialog("res://dialog/innerMonologue/no_shovel.json")
		
	if is_in_group("stone3"):
		if hotbarglobal.inventory_items.has("shovel"):
			GameState.puzzle_state[save_id] = true
			TransitionAreaFade.transition()
			await TransitionAreaFade.transition_finished
			GameState.return_scene_path = get_tree().current_scene.scene_file_path
			get_tree().change_scene_to_file("res://scenes/Cutscenes/finding_sam.tscn")
			GameState.puzzle_state["outside2_second_unlocked"] = true
			remove_stones()
		else:
			DialogManager.start_dialog("res://dialog/innerMonologue/no_shovel.json")
		
	if not is_in_group("stones"):
		print("not in group stones")
		#remove_stones()
#
#
func remove_stones():
	TransitionAreaFade.transition()
	await TransitionAreaFade.transition_finished
	queue_free()
