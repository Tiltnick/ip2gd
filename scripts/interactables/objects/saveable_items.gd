extends Interactable
# für die Interaktion
class_name SaveableItem

# Eindeutige ID zugewiesen + Namen
var save_id: String = ""
var item_name_de: String = ""
var item_name_en: String = ""
var item_id: String = ""

@export var item_icon: Texture2D 

func _ready() -> void:
# super._ready() -> ready Funktion von Interactable
	super._ready()

	add_to_group("collectible_items")

# Check im GameState
	if save_id != "" and GameState.puzzle_state.get(save_id, false):
		queue_free()

# Eintrag in puzzle_state
func mark_collected() -> void:
	var lang = TranslationServer.get_locale().substr(0, 2)
	if save_id != "":
		GameState.puzzle_state[save_id] = true
		#found item popup
		if lang == "de":
			PopupManager.popup_item_de(item_name_de, item_icon)
		elif lang == "en":
			PopupManager.popup_item_en(item_name_en, item_icon)
