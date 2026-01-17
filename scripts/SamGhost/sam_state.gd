extends Node
class_name SamState

signal state_transition(target_state: String)

var npc: NPC
var machine: SamStateMachine

func Enter(_prev) -> void:
	pass

func Exit() -> void:
	pass

func Update(_delta: float) -> void:
	pass

func PhysicsUpdate(_delta: float) -> void:
	pass

func TransitionTo(state_name: String) -> void:
	state_transition.emit(state_name)
