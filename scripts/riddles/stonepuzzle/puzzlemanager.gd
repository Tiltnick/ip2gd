extends Control

@onready var cells: Node2D = $Cells
@onready var cell_scene = preload("res://scenes/Riddles/stonepuzzle/cell.tscn")
#@onready var pieces: Node2D = $Pieces
@onready var piece_scene = preload("res://scenes/Riddles/stonepuzzle/pieces.tscn")

func _ready() -> void:
	init_game()

func init_game():
	draw_cells()

func draw_cells():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
