extends SaveableItem
@export var diary_entry_id: String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact() -> void:
	# falls aus irgendeinem Grund schon eingesammelt → nichts tun
	if GameState.puzzle_state.get(save_id, false):
		return
	
	Diary.unlock_entry(diary_entry_id)
	
	GameState.puzzle_state[save_id] = true
	
	mark_collected()
	queue_free()
	
	QuestManager.add_quest("quest_8")
