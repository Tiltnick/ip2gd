extends Area2D

@export var npc_path: NodePath
@export var solved_flag: String = "outside5_pillar_puzzle_solved"

@export var puzzle_path: NodePath

@onready var npc: Node = get_node(npc_path)

var _triggered: bool = false


func _ready() -> void:
	if _is_solved():
		_disable_trigger()
		return

	body_entered.connect(Callable(self, "_on_body_entered"))

	if not puzzle_path.is_empty():
		var puzzle := get_node_or_null(puzzle_path)
		if puzzle != null and puzzle.has_signal("puzzle_solved"):
			puzzle.connect("puzzle_solved", Callable(self, "_on_puzzle_solved"))


func _on_puzzle_solved() -> void:
	_disable_trigger()


func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if _is_solved():
		_disable_trigger()
		return

	if not body.is_in_group("player"):
		return

	_triggered = true
	_disable_trigger()

	if is_instance_valid(npc):
		npc.on_player_triggered(body)


func _disable_trigger() -> void:
	monitoring = false
	monitorable = false

	var shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape != null:
		shape.disabled = true


func _is_solved() -> bool:
	if solved_flag.is_empty():
		return false
	return bool(GameState.puzzle_state.get(solved_flag, false))
