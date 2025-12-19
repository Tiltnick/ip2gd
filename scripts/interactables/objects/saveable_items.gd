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
	var lang = TranslationServer.get_locale().substr(0, 2)
	if save_id == "cave_note":
		GameState.puzzle_state[save_id] = true
		if lang == "de":
			PopupManager.popup_diary_de()
		elif lang == "en":
			PopupManager.popup_diary_en()

	if save_id != "cave_note":
		GameState.puzzle_state[save_id] = true
		if lang == "de":
			PopupManager.popup_item_de(item_name_de, item_icon)
		elif lang == "en":
			PopupManager.popup_item_en(item_name_en, item_icon)
	SaveSystem.save_game()
