extends Interactable
class_name SpaceshipGiveFluxomat

const SAVE_KEY := "fluxomat"
const ITEM_ID  := "fluxomat"
@export var dialog_path := "res://dialog/outside2/find_fluxomat.json"


func interact() -> void:
	SfxPlayer.ui_click_sound()

	# give_item regelt Save + Inventar + Popup
	if not hotbarglobal.give_item(ITEM_ID, SAVE_KEY):
		return

	if dialog_path != "":
		DialogManager.start_dialog(dialog_path)


	# Dialog
	if dialog_path != "":
		DialogManager.start_dialog(dialog_path)
	
