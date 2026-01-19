extends Area2D

@export var npc_path: NodePath

@onready var npc: Node = get_node(npc_path)

var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	if _triggered:
		return

	if not body.is_in_group("player"):
		return

	_triggered = true

	monitoring = false
	monitorable = false

	if is_instance_valid(npc):
		npc.on_player_triggered(body)
