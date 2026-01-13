extends Node
class_name GhostStateMachine

@export var initial_state: GhostState

var current_state: GhostState
var states: Dictionary = {}

func _ready() -> void:
	var ghost := get_parent() as SamGhost

	for child in get_children():
		if child is GhostState:
			var state := child as GhostState
			state.ghost = ghost
			state.machine = self
			states[state.name.to_lower()] = state
			state.state_transition.connect(_on_state_transition)

	if initial_state:
		current_state = initial_state
		current_state.Enter(null)

func request_transition(target_state: String) -> void:
	_on_state_transition(target_state)

func _on_state_transition(target_state: String) -> void:
	var key := target_state.to_lower()
	if not states.has(key):
		push_warning("Unknown Ghost state: %s" % target_state)
		return

	var next := states[key] as GhostState
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

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.PhysicsUpdate(delta)
