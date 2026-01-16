extends Node
class_name NpcStateMachine

var npc: Node = null
var states: Dictionary = {}
var current_state: Node = null

var _is_transitioning: bool = false
var _queued_state: String = ""


func init(_npc: Node) -> void:
	npc = _npc
	states.clear()

	for child in get_children():
		states[child.name] = child
		if child.has_method("setup"):
			child.setup(npc, self)

	transition_to("Idle")


func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		push_warning("StateMachine: unknown state '%s'" % state_name)
		return

	if _is_transitioning:
		_queued_state = state_name
		return

	_is_transitioning = true

	var prev := current_state
	current_state = null
	if prev != null and prev.has_method("exit"):
		prev.exit()

	current_state = states[state_name]
	if current_state != null and current_state.has_method("enter"):
		current_state.enter()

	_is_transitioning = false

	if _queued_state != "":
		var next := _queued_state
		_queued_state = ""
		transition_to(next)


func _physics_process(delta: float) -> void:
	if current_state != null and current_state.has_method("physics_update"):
		current_state.physics_update(delta)
