extends SaveableItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_id = "cave_note"
	super._ready()

func interact() -> void:
	# falls aus irgendeinem Grund schon eingesammelt → nichts tun
	if GameState.puzzle_state.get(save_id, false):
		return
		
	Diary.unlock_entry("entry_3")
	print(Diary.unlocked_entries)
	
	GameState.puzzle_state[save_id] = true
	
	mark_collected()
	queue_free()
	
	QuestManager.add_quest("quest_8")
