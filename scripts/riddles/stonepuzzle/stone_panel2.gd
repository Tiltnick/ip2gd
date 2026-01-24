extends Interactable
@onready var puzzle: CanvasLayer = $"../Puzzle"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
func interact():
	SfxPlayer.ui_click_sound()
	puzzle.open_puzzle()
