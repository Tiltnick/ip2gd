extends Node
class_name NPCStateMachine

# Init state ist hier move
@export var initial_state: NPCState

var current_state: NPCState
var states = {}


func _ready() -> void:
	var npc = get_parent() as NPC

# States registrieren
	for child in get_children():
		if child is NPCState:
			states[child.name.to_lower()] = child
			child.machine = self
			child.npc = npc
			child.state_transition.connect(_on_state_transition)

# Init state bei NPC = move
	if initial_state:
		current_state = initial_state
		current_state.Enter(null)

# Transition
func _on_state_transition(target: String) -> void:
	change_state(target)


func change_state(target: String) -> void:
	var next: NPCState = states.get(target.to_lower())
	if next == null or next == current_state:
		return

	var prev := current_state
	prev.Exit()

	current_state = next
	current_state.Enter(prev)


func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

# Wichtig für Kollision
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.PhysicsUpdate(delta)
