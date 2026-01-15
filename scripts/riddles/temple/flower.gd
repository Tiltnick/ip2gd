extends Node2D
class_name ReplaceWithFlower

@export var puzzle_path: NodePath
@export var solved_flag: String = "outside5_pillar_puzzle_solved"

@export var flower_scene: PackedScene

var _replaced := false


func _ready() -> void:
	if solved_flag != "" and bool(GameState.puzzle_state.get(solved_flag, false)):
		_replace_now()
		return

	if puzzle_path != NodePath() and has_node(puzzle_path):
		var puzzle := get_node(puzzle_path)
		if puzzle and puzzle.has_signal("puzzle_solved"):
			puzzle.puzzle_solved.connect(_on_puzzle_solved)


func _on_puzzle_solved() -> void:
	_replace_now()


func _replace_now() -> void:
	if _replaced:
		return
	_replaced = true

	if flower_scene == null:
		return

	var flower := flower_scene.instantiate()
	flower.global_position = global_position

	var parent := get_parent()
	if parent:
		parent.add_child(flower)

	queue_free()
