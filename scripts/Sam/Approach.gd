extends Node

var npc
var sm

@export var stop_distance: float = 32.0


func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	if npc.has_method("stop_and_idle"):
		npc.stop_and_idle()


func physics_update(_delta: float) -> void:
	if npc.player == null:
		sm.transition_to("Idle")
		return

	npc.move_towards(npc.player.global_position)

	if npc.global_position.distance_to(npc.player.global_position) <= stop_distance:
		if npc.has_method("stop_and_idle"):
			npc.stop_and_idle()
		sm.transition_to("Talk")


func exit() -> void:
	pass
