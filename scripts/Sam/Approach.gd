extends Node

var npc
var sm

@export var stop_distance: float = 32.0


func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	# optional: direkt stehen bleiben/Reset
	pass


func physics_update(_delta: float) -> void:
	if npc.player == null:
		sm.transition_to("Idle")
		return

	# zum Player laufen
	npc.move_towards(npc.player.global_position)

	# nah genug -> Talk
	if npc.global_position.distance_to(npc.player.global_position) <= stop_distance:
		npc.velocity = Vector2.ZERO
		npc.move_and_slide()
		sm.transition_to("Talk")


func exit() -> void:
	npc.velocity = Vector2.ZERO
