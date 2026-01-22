extends Node2D

@onready var tutorial := $Tutorial_UI

func _ready() -> void:

	if not GameState.puzzle_state.get("wakeup_done", false):
		GameState.puzzle_state["wakeup_done"] = true
		DialogManager.start_dialog("res://dialog/innerMonologue/wakeup.json")
		
		await DialogManager.dialog_finished
		QuestManager.add_quest("quest_1")
		tutorial.visible = true
		
