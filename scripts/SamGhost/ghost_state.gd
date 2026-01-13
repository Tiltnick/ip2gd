extends Node
class_name GhostState

signal state_transition(target_state: String)

var machine: GhostStateMachine
var ghost: SamGhost

func Enter(_prev: GhostState) -> void:
	pass

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func PhysicsUpdate(_delta: float) -> void:
	pass

func TransitionTo(target: String) -> void:
	state_transition.emit(target)
