extends Interactable
class_name SaveableItem

@export var save_id: String = ""
@export var item_name_de: String = ""
@export var item_name_en: String = ""
@export var item_icon: Texture2D

@export var spawned_from_hotbar: bool = false  

@export var add_to_inventory: bool = true


func _ready() -> void:
	super._ready()
	add_to_group("collectible_items")

	if not spawned_from_hotbar and save_id != "" and GameState.puzzle_state.get(save_id, false):
		queue_free()


func mark_collected() -> void:
	if save_id == "":
		return

	# Item als eingesammelt markieren
	GameState.puzzle_state[save_id] = true

	# Item  im GameState vormerken
	if add_to_inventory and not GameState.inventory_slots.has(save_id):
		for i in range(GameState.inventory_slots.size()):
			if GameState.inventory_slots[i] == null:
				GameState.inventory_slots[i] = save_id
				break





	# Popup
	if save_id == "cave_note":
		PopupManager.popup_diary()
	else:
		show_item_popup()

	# Quest-Tracking 
	if not GameState.picked_items.has(save_id):
		GameState.picked_items.append(save_id)
		QuestManager.on_item_picked(save_id)
		if has_node("/root/AnalyticsLogger"):
			AnalyticsLogger.log_item_collected(save_id, {
				"node_path": str(get_path())
			})

	SaveSystem.save_game()




func show_item_popup():
	var lang = TranslationServer.get_locale().substr(0,2)
	if lang == "de":
		PopupManager.popup_item(item_name_de, item_icon)
	if lang == "en":
		PopupManager.popup_item(item_name_en, item_icon)
