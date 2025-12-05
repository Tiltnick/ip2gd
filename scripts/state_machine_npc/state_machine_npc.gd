extends Node
class_name NPCStateMachine

# Initialer State
@export var initial_state: NPCState

var current_state: NPCState
var states: Dictionary = {}


func _ready() -> void:
	var npc := get_parent() as NPC

	# States registrieren
	for child in get_children():
		if child is NPCState:
			var state := child as NPCState
			state.npc = npc
			state.machine = self
			states[state.name.to_lower()] = state
			state.state_transition.connect(_on_state_transition)

	# Initialen State setzen
	if initial_state:
		current_state = initial_state
		current_state.Enter(null)


func _on_state_transition(target_state: String) -> void:
	var key := target_state.to_lower()
	if not states.has(key):
		push_warning("Unknown NPC state: %s" % target_state)
		return

	var next := states[key] as NPCState
	if next == current_state:
		return

	var prev := current_state
	if prev:
		prev.Exit()

	current_state = next
	current_state.Enter(prev)


func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)


# Collisions
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.PhysicsUpdate(delta)
