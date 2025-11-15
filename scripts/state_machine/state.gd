extends Node
class_name State

# State nodes erben von state.gd

signal state_transition(target_state: String)

var machine
var actor: MainCharacter

# Betreten der state animation
func Enter(_prev: State) -> void: 
	pass

# Verlassen state
func Exit() -> void: 
	pass

# Input handling
func HandleInput(_event: InputEvent) -> void: 
	pass

# Logik
func Update(_delta: float) -> void: 
	pass

# Bewegung / Phsysik
func PhysicsUpdate(_delta: float) -> void: 
	pass

# State wechseln
func TransitionTo(target: String) -> void:
	state_transition.emit(target)
