extends Node

var npc
var sm


func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	npc.velocity = Vector2.ZERO
	npc.move_and_slide()


func physics_update(_delta: float) -> void:
	# Nichts tun – SAM wartet. Interact wird in SAM._unhandled_input abgefangen.
	pass


func exit() -> void:
	pass
