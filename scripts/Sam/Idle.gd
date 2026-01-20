extends Node

var npc
var sm

func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	if npc.has_method("stop_and_idle"):
		npc.stop_and_idle()
	else:
		npc.velocity = Vector2.ZERO
		npc.move_and_slide()


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
