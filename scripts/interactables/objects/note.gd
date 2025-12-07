extends SaveableItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_id = "cave_note"
	super._ready()


func interact() -> void:
	# falls aus irgendeinem Grund schon eingesammelt → nichts tun
	if GameState.puzzle_state.get(save_id, false):
		return
		
	print("Notiz eingesammelt!")
	
	mark_collected()
	queue_free()
