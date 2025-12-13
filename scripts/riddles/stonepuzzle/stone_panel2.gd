extends Interactable
@onready var puzzle: CanvasLayer = $"../Puzzle"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super ._ready()
func interact():
	puzzle.show()
