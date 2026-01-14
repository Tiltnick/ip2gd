extends Node
class_name SamStateMachine

@export var initial_state: SamState
@export var start_move_state_name: String = "move"
@export var first_dialog_done_flag: String = "sam_outside5_first_dialog_done"

# Cutscene
@export var cutscene_target_name: String = "SamCutsceneCameraTarget"
@export var cutscene_zoom_out: Vector2 = Vector2(0.7, 0.7)
@export var tween_time: float = 0.6

@onready var npc: NPC = get_parent() as NPC

var current_state: SamState
var states: Dictionary = {}

var _dialog_started_by_me: bool = false
var _is_moving: bool = false

var _player: Node = null
var _frozen_nodes: Array[Dictionary] = [] 

var _camera: Camera2D = null
var _old_zoom: Vector2 = Vector2.ONE
var _old_cam_pos: Vector2 = Vector2.ZERO
var _tween: Tween = null


func _ready() -> void:
	if npc == null:
		push_warning("SamStateMachine: Parent ist kein NPC.")
		return

	_register_states()
	_enter_initial_state()

	_player = get_tree().get_first_node_in_group("player")

	
	if DialogManager and DialogManager.has_signal("dialog_finished"):
		DialogManager.dialog_finished.connect(_on_dialog_finished)


func _exit_tree() -> void:
	_freeze_player_tree(false)

	if DialogManager and DialogManager.has_signal("dialog_finished"):
		if DialogManager.dialog_finished.is_connected(_on_dialog_finished):
			DialogManager.dialog_finished.disconnect(_on_dialog_finished)


func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.PhysicsUpdate(delta)


func notify_dialog_started_by_this_npc() -> void:
	_dialog_started_by_me = true


func notify_move_finished() -> void:
	_is_moving = false
	_end_cutscene()


# Dialog startet move

func _on_dialog_finished() -> void:
	if not _dialog_started_by_me:
		return
	_dialog_started_by_me = false

	npc.dialog_active = false
	if npc.e_popup_node and npc.player_inside:
		npc.e_popup_node.visible = true


	if not npc.player_inside:
		return

	if bool(GameState.puzzle_state.get(first_dialog_done_flag, false)):
		return

	if npc.path_follow == null:
		push_warning("SamStateMachine: npc.path_follow ist null (Outside5/sam_follow zuweisen).")
		return

	GameState.puzzle_state[first_dialog_done_flag] = true
	_start_move_once()


func _start_move_once() -> void:
	if _is_moving:
		return
	_is_moving = true

	_start_cutscene()

	npc.path_follow.progress = 0.0
	npc.global_position = npc.path_follow.global_position

	_change_state(start_move_state_name)


# State machine sam

func _register_states() -> void:
	for child in get_children():
		if child is SamState:
			var s := child as SamState
			s.npc = npc
			s.machine = self
			states[s.name.to_lower()] = s
			s.state_transition.connect(_on_state_transition)


func _enter_initial_state() -> void:
	if initial_state == null:
		if states.has("idle"):
			initial_state = states["idle"]
		elif states.size() > 0:
			initial_state = states.values()[0]

	current_state = initial_state
	if current_state:
		current_state.Enter(null)


func _on_state_transition(target_state: String) -> void:
	_change_state(target_state)


func _change_state(target_state: String) -> void:
	var key := target_state.to_lower()
	if not states.has(key):
		push_warning("SamStateMachine: Unknown state '%s'" % target_state)
		return

	var next := states[key] as SamState
	if next == current_state:
		return

	var prev := current_state
	if current_state:
		current_state.Exit()

	current_state = next
	current_state.Enter(prev)


# Cam cutscene

func _start_cutscene() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_freeze_player_tree(true)

	_camera = _get_current_camera()
	if _camera == null:
		return

	_old_zoom = _camera.zoom
	_old_cam_pos = _camera.global_position

	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)

	_tween.tween_property(_camera, "zoom", cutscene_zoom_out, tween_time)

	var target := _find_cutscene_target()
	if target:
		_tween.tween_property(_camera, "global_position", target.global_position, tween_time)


func _end_cutscene() -> void:
	_freeze_player_tree(false)

	if _camera == null:
		return

	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)

	_tween.tween_property(_camera, "zoom", _old_zoom, tween_time)
	_tween.tween_property(_camera, "global_position", _old_cam_pos, tween_time)


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null


func _freeze_player_tree(freeze: bool) -> void:
	if _player == null:
		return

	if freeze:
		if _frozen_nodes.size() > 0:
			return

		_frozen_nodes.clear()
		_collect_tree(_player)

		for item in _frozen_nodes:
			var n: Node = item["node"]
			n.process_mode = Node.PROCESS_MODE_DISABLED

		if _player is CharacterBody2D:
			(_player as CharacterBody2D).velocity = Vector2.ZERO

	else:
		for item in _frozen_nodes:
			var n: Node = item["node"]
			var mode: int = item["mode"]
			if is_instance_valid(n):
				n.process_mode = mode

		_frozen_nodes.clear()


func _collect_tree(root: Node) -> void:
	_frozen_nodes.append({"node": root, "mode": root.process_mode})
	for c in root.get_children():
		_collect_tree(c)


func _find_cutscene_target() -> Node2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	# direkter Node im Root
	var direct := scene.get_node_or_null(cutscene_target_name)
	if direct and direct is Node2D:
		return direct

	# rekursiv suchen
	return _find_node_by_name(scene, cutscene_target_name) as Node2D


func _find_node_by_name(root: Node, wanted: String) -> Node:
	if root.name == wanted:
		return root
	for c in root.get_children():
		var res := _find_node_by_name(c, wanted)
		if res:
			return res
	return null


func _get_current_camera() -> Camera2D:
	var vp := get_viewport()
	if vp:
		var c := vp.get_camera_2d()
		if c:
			return c

	var scene := get_tree().current_scene
	if scene:
		var sc := scene.get_node_or_null("SceneCamera")
		if sc and sc is Camera2D:
			return sc

	if _player:
		var pc := _player.get_node_or_null("Camera2D")
		if pc and pc is Camera2D:
			return pc

	return null
