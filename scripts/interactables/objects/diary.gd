extends SaveableItem

func _ready() -> void:
# Jedes Item braucht eine ID
	save_id = "spaceship_diary"
	item_name_de = "Tagebuch"
	item_name_en = "Diary"
	
# _ready func von Interactable wird aufgerufen -> queue_free() wenn es eingesammelt ist
	super._ready()  


func interact() -> void:
	# falls aus irgendeinem Grund schon eingesammelt → nichts tun
	# TODO besseren sound finden 
	SfxPlayer.ui_click_sound()
	
	if GameState.puzzle_state.get(save_id, false):
		return
	print("Buch eingesammelt!")
	mark_collected()
	GlobalMenuButton.show()
	queue_free()
