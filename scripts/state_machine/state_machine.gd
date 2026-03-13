extends Node
class_name StateMachine

# Init state = idle
@export var initial_state: State
@export var dialog_manager_path: NodePath       

var current_state: State
var states: Dictionary = {}

var state_before_dialog: State = null         


func _ready() -> void:
	# Actor ist der Parent
	var actor: MainCharacter = get_parent() as MainCharacter

	# States einsammeln und registrieren
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.machine = self
			child.actor = actor
			child.state_transition.connect(_on_state_transition)


	if initial_state:
		current_state = initial_state
		current_state.Enter(null)

	
	var dm: Node = null


	if dialog_manager_path == NodePath():  
		dm = DialogManager

	elif has_node(dialog_manager_path):
		dm = get_node(dialog_manager_path)

	if dm != null:
		if not dm.dialog_started.is_connected(_on_dialog_started):
			dm.dialog_started.connect(_on_dialog_started)
		if not dm.dialog_finished.is_connected(_on_dialog_finished):
			dm.dialog_finished.connect(_on_dialog_finished)

		
		if dm.is_running:
			_on_dialog_started()
	


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


func _on_dialog_started() -> void:
	state_before_dialog = current_state
	change_state("dialog")         


func _on_dialog_finished() -> void:
	if state_before_dialog != null:
		change_state(state_before_dialog.name.to_lower())
		state_before_dialog = null
	else:
		change_state("idle")


#func _on_dialog_finished() -> void:
	#if state_before_dialog != null:
		#change_state("idle")
	#else:
		#change_state("idle")
		#change_state(state_before_dialog.name.to_lower())
		#state_before_dialog = null



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
		MovementTracker.track_sample(get_parent() as CharacterBody2D, current_state.name, delta)
