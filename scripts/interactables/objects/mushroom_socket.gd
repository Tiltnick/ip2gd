extends Interactable
@onready var mushroom_ui: CanvasLayer = $"../MushroomUi"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func interact():
	SfxPlayer.ui_click_sound()
	if GameState.puzzle_state.has("stone_puzzle"):
		mushroom_ui.open_socket()
	else: 
		DialogManager.start_dialog("res://dialog/innerMonologue/mush_socket_dialogue.json")
