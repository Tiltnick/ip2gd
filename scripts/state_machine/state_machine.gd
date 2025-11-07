extends Node
class_name StateMachine

@export var initialState : State

var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.stateTransition.connect(change_state)
			
	if initialState:
		initialState.Enter()
		currentState = initialState
		
func changeState(oldState: State, new_state_name : String):
	
