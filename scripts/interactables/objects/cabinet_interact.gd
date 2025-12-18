extends Interactable
class_name CabinetGiveTelescope

const SAVE_KEY := "telescope1"  #  Save-State Key
const ITEM_ID  := "telescope"   # ItemDatabase Key / hotbar_id

@export var dialog_path := ""   #falls dialohue für cab

func interact() -> void:
	SfxPlayer.ui_click_sound()

	# nur einmal geben
	if GameState.puzzle_state.get(SAVE_KEY, false):
		return

	# Save-State setzen
	GameState.puzzle_state[SAVE_KEY] = true

	# Item in Hotbar + Inventory
	hotbarglobal.add_item(ITEM_ID)

	

	# optionaler dialohe
	if dialog_path != "":
		DialogManager.start_dialog(dialog_path)












#extends ZoomStoreItem
#class_name TelescopeItem
#
#func _ready() -> void:
	#save_id = "telescope1"
	#hotbar_id = "telescope"
#
	#item_name_de = "Teleskop"
	#item_name_en = "Telescope"
	#super._ready()
#
#func interact() -> void:
	## In der Welt: direkt einsammeln, kein Zoom
	#if not spawned_from_hotbar:
		#_store_in_hotbar()
		#return
#
	## Aus der Hotbar: normale Zoom-Logik
	#super.interact()
#
#
	### Falls schon geöffnet gespeichert:
	##if save_id != "" and GameState.puzzle_state.get(save_id, false):
		##opened = true
		##anim.frame = anim.sprite_frames.get_frame_count("open") - 1
		##anim.stop()
#
##func interact() -> void:
	##if opened:
		##return
##
	##opened = true
	##if save_id != "":
		##GameState.puzzle_state[save_id] = true
##
	##anim.play("open")
	#
