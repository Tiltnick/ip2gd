extends Node
class_name StateMachine

# Init state = idle
@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Actor ist der Parent (MainCharacter)
	var actor: MainCharacter = get_parent() as MainCharacter

	# States einsammeln und registrieren
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.machine = self
			child.actor = actor
			child.state_transition.connect(_on_state_transition)

	# Initiale state = idle (im @export)
	if initial_state:
		current_state = initial_state
		current_state.Enter(null)

# Empfang Signal
func _on_state_transition(target: String) -> void:
	change_state(target)

# Wechsel states
func change_state(target: String) -> void:
	# Nächster state
	var next: State = states.get(target.to_lower())
	if next == null or next == current_state:
		return

# Vorheriger state
	var prev := current_state
	if prev:
		prev.Exit()

	current_state = next
	current_state.Enter(prev)

# Eingaben weiterleiten
func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.HandleInput(event)

# Frame Logik aktueller state
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

# Physik Logik aktueller state
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.PhysicsUpdate(delta)
