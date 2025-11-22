extends SaveableItem

func _ready() -> void:
# Jedes Item braucht eine ID
	save_id = "spaceship_diary"
# _ready func von Interactable wird aufgerufen -> queue_free() wenn es eingesammelt ist
	super._ready()  


func interact() -> void:
	# falls aus irgendeinem Grund schon eingesammelt → nichts tun
	if GameState.puzzle_state.get(save_id, false):
		return

	print("Buch eingesammelt!")

	# im GameState als eingesammelt markieren
	mark_collected()
	GameMenu.show()
	queue_free()
