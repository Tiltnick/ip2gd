extends Node2D
@export var sockets_group := "socket"
@onready var collision: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision.body_entered.connect(_on_body_entered)
	collision.body_exited.connect(_on_body_exited)


func _on_body_entered() -> void:
	_set_all_outlines(true)

func _on_body_exited() -> void:
	_set_all_outlines(false)

func _set_all_outlines(visible: bool) -> void:
	# Option A: über Gruppe "socket"
	for s in get_tree().get_nodes_in_group(sockets_group):
		var o := s.get_node_or_null("Outline")
		if o:
			o.visible = visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
