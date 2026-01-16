extends Area2D

@export var npc_path: NodePath
@onready var npc := get_node(npc_path)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		npc.on_player_triggered(body)
