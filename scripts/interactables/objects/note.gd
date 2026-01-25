extends SaveableItem
@export var diary_entry_id: String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact() -> void:
	if GameState.picked_items.has("cave_note") and GameState.picked_items.has("mush_item") and GameState.picked_items.has("temple_note"):
		QuestManager.complete_quest("quest_8")

	
	if GameState.puzzle_state.get(save_id, false):
		return

	Diary.unlock_entry(diary_entry_id)
	GameState.puzzle_state[save_id] = true

	if not GameState.picked_items.has(diary_entry_id):
		GameState.picked_items.append(diary_entry_id)
		QuestManager.on_item_picked(diary_entry_id)

	mark_collected()
	queue_free()

	QuestManager.add_quest("quest_8")
	
