extends Interactable
@onready var riddle_statue: CanvasLayer = $"../riddle_statue"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
func interact() -> void:
	QuestManager.add_quest("quest_6")

	if TripodManager.all_interacted():
		riddle_statue.open_puzzle()
	else:
		DialogManager.start_dialog("res://dialog/innerMonologue/no_telescope.json")
