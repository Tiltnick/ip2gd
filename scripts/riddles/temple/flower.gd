extends Node2D
class_name ReplaceWithFlower

@export var puzzle_path: NodePath
@export var solved_flag: String = "outside5_pillar_puzzle_solved"
@export var flower_scene: PackedScene

var _replaced: bool = false


func _ready() -> void:
	if _is_solved():
		_replace_now()
		return

	if not puzzle_path.is_empty():
		var puzzle := get_node_or_null(puzzle_path)
		if puzzle != null and puzzle.has_signal("puzzle_solved"):
			puzzle.connect("puzzle_solved", Callable(self, "_on_puzzle_solved"))


func _on_puzzle_solved() -> void:
	_replace_now()


func _replace_now() -> void:
	if _replaced:
		return
	_replaced = true

	if flower_scene == null:
		return

	var flower := flower_scene.instantiate() as Node2D
	if flower != null:
		flower.global_position = global_position

		var parent := get_parent()
		if parent != null:
			parent.add_child(flower)

	queue_free()


func _is_solved() -> bool:
	if solved_flag.is_empty():
		return false
	return bool(GameState.puzzle_state.get(solved_flag, false))
