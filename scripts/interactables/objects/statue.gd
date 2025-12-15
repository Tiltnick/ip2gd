extends Interactable
@onready var riddle_statue: CanvasLayer = $"../riddle_statue"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
func interact():
	riddle_statue.open_puzzle()
