extends Interactable
class_name SpaceshipGiveFluxomat

const SAVE_KEY := "fluxomat"
const ITEM_ID  := "fluxomat"
@export var dialog_path := "res://dialog/outside2/find_fluxomat.json"

func interact() -> void:
	SfxPlayer.ui_click_sound()

	# nur beim ersten Mal geben
	if GameState.puzzle_state.get(SAVE_KEY, false):
		return

	# Save-State setzen
	GameState.puzzle_state[SAVE_KEY] = true

	# Item in Hotbar + Inventory
	hotbarglobal.add_item(ITEM_ID)

	# Popup
	_show_item_popup()

	# Dialog
	if dialog_path != "":
		DialogManager.start_dialog(dialog_path)
		#await DialogManager.dialog_finished
		#QuestManager.complete_quest("quest2")


func _show_item_popup() -> void:
	if not ItemDatabase.DATA.has(ITEM_ID):
		return

	var data: Dictionary = ItemDatabase.DATA[ITEM_ID]
	var lang: String = TranslationServer.get_locale().substr(0, 2)

	var title: String = String(
		data.get("name_de", ITEM_ID) if lang == "de" else data.get("name_en", ITEM_ID)
	)

	var icon_path: String = String(data.get("icon", ""))
	if icon_path == "":
		return

	var tex: Texture2D = load(icon_path) as Texture2D
	if tex == null:
		return

	if lang == "de":
		PopupManager.popup_item_de(title, tex)
	else:
		PopupManager.popup_item_en(title, tex)






#extends ZoomStoreItem
#class_name Fluxomat
#
#func _ready() -> void:
	#save_id = "fluxomat"
	#hotbar_id = "fluxomat"
#
	#item_name_de = "Fluxomat"
	#item_name_en = "Fluxomat"
	#super._ready()
#
#func interact() -> void:
	## nur beim ersten Mal einsammeln den Dialog starten
	#if not spawned_from_hotbar:
		#if save_id != "" and GameState.puzzle_state.get(save_id, false):
			#return
#
		#_store_in_hotbar()
		#_on_interacted()
		#return
#
	## Aus der Hotbar: normale Zoom-Logik
	#super.interact()
#
#
#func _on_interacted() -> void:
	#DialogManager.start_dialog("res://dialog/outside2/find_fluxomat.json")
