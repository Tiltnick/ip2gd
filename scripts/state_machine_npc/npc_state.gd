extends Node
# States erben von npc_state.gd
class_name NPCState

signal state_transition(target_state: String)

var machine: NPCStateMachine
var npc: NPC


func Enter(_prev: NPCState) -> void:
	pass


func Exit() -> void:
	pass


func Update(_delta: float) -> void:
	pass


func PhysicsUpdate(_delta: float) -> void:
	pass


func TransitionTo(target: String) -> void:
	state_transition.emit(target)
