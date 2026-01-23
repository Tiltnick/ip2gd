extends Interactable
class_name SaveableItem

@export var save_id: String = ""
@export var item_name_de: String = ""
@export var item_name_en: String = ""
@export var item_icon: Texture2D

@export var spawned_from_hotbar: bool = false  

func _ready() -> void:
	super._ready()
	add_to_group("collectible_items")

	if not spawned_from_hotbar and save_id != "" and GameState.puzzle_state.get(save_id, false):
		queue_free()

func mark_collected() -> void:
	if save_id == "cave_note":
		GameState.puzzle_state[save_id] = true
		PopupManager.popup_diary()

	if save_id != "cave_note":
		GameState.puzzle_state[save_id] = true
		PopupManager.popup_item(item_name_de, item_icon)
	
	if save_id != "" and not GameState.picked_items.has(save_id):
		GameState.picked_items.append(save_id)
		QuestManager.on_item_picked(save_id)
	
	SaveSystem.save_game()
	print("")
