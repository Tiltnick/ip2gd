extends Node
class_name SamStateMachine

signal demo_finished

# Exports 
@export var initial_state: SamState
@export var start_move_state_name: String = "move"
@export var path_follow_names: Array[String] = ["sam_follow", "sam_follow_2", "sam_follow_3"]

@export var cutscene_camera_name: String = "CutsceneCamera"
@export var cutscene_target_name: String = "SamCutsceneCameraTarget"
@export var cutscene_zoom_out: Vector2 = Vector2(0.7, 0.7)
@export var tween_time: float = 0.6

@export var segment_index_key: String = "sam_outside5_segment_index"
@export var failed_flag: String = "outside5_pillar_puzzle_failed"

@export var cutscene_failsafe_seconds: float = 0.0

# Nodes
@onready var npc: NPC = get_parent() as NPC

# State machine
var current_state: SamState
var states: Dictionary = {}

# Flow
var _dialog_started_by_me := false
var _demo_mode := false
var _pending_retry_demo := false
var _segment_index := 0

# Freeze
const _FROZEN_NODE_KEY := "node"
const _FROZEN_MODE_KEY := "mode"

var _player: Node = null
var _frozen_nodes: Array[Dictionary] = []

# Camera / Cutscene
var _cutscene_cam: Camera2D = null
var _tween: Tween = null

var _player_cam: Camera2D = null
var _player_cam_start_zoom: Vector2 = Vector2.ONE
var _player_cam_start_pos: Vector2 = Vector2.ZERO

var _cutscene_active := false
var _cutscene_ending := false
var _failsafe_timer: Timer = null


func _ready() -> void:
	if npc == null:
		push_warning("SamStateMachine: Parent ist kein NPC.")
		return

	add_to_group("sam_state_machine")

	_register_states()
	_enter_initial_state()

	_player = _get_player()
	_segment_index = _get_segment_index()

	_failsafe_timer = Timer.new()
	_failsafe_timer.one_shot = true
	_failsafe_timer.autostart = false
	_failsafe_timer.timeout.connect(_on_cutscene_failsafe_timeout)
	add_child(_failsafe_timer)

	if DialogManager and DialogManager.has_signal("dialog_finished"):
		DialogManager.dialog_finished.connect(_on_dialog_finished)


func _exit_tree() -> void:
	_force_end_cutscene_immediate_to_player()

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
	_segment_index += 1
	_set_segment_index(_segment_index)

	if _demo_mode:
		if _segment_index < path_follow_names.size():
			_start_segment_by_index(_segment_index)
			return

		_demo_mode = false
		demo_finished.emit()
		return


func on_puzzle_failed() -> void:
	_force_end_cutscene_immediate_to_player()
	_set_failed_flag(true)

	_segment_index = 0
	_set_segment_index(0)

	var follow := _resolve_path_follow_by_name(path_follow_names[0])
	if follow:
		_apply_path_follow(follow)

	_pending_retry_demo = true
	_demo_mode = false
	_change_state("idle")


#Dialog
func _on_dialog_finished() -> void:
	if not _dialog_started_by_me:
		return
	_dialog_started_by_me = false

	npc.dialog_active = false
	if npc.e_popup_node and npc.player_inside:
		npc.e_popup_node.visible = true

	if not npc.player_inside:
		return

	if _pending_retry_demo:
		_pending_retry_demo = false
		_set_failed_flag(false)
		_start_demo_from_beginning()
		return

	if _demo_mode:
		return

	if _segment_index >= path_follow_names.size():
		return

	_start_single_segment_after_dialog()


func _start_single_segment_after_dialog() -> void:
	_start_cutscene()
	_start_segment_by_index(_segment_index)


func _start_demo_from_beginning() -> void:
	_demo_mode = true
	_segment_index = 0
	_set_segment_index(0)

	_start_cutscene()
	_start_segment_by_index(0)


# Segment control
func _start_segment_by_index(idx: int) -> void:
	if idx < 0 or idx >= path_follow_names.size():
		_demo_mode = false
		demo_finished.emit()
		return

	var follow := _resolve_path_follow_by_name(path_follow_names[idx])
	if follow == null:
		push_warning("SamStateMachine: Konnte PathFollow2D '%s' nicht finden." % path_follow_names[idx])
		_demo_mode = false
		demo_finished.emit()
		return

	_apply_path_follow(follow)
	_change_state(start_move_state_name)


func _apply_path_follow(follow: PathFollow2D) -> void:
	npc.path_follow = follow
	npc.path_follow.progress = 0.0
	npc.global_position = npc.path_follow.global_position


func _resolve_path_follow_by_name(name_in_scene: String) -> PathFollow2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var direct := scene.get_node_or_null(name_in_scene)
	if direct is PathFollow2D:
		return direct as PathFollow2D

	var found := _find_node_by_name(scene, name_in_scene)
	if found is PathFollow2D:
		return found as PathFollow2D

	return null


# SM
func _register_states() -> void:
	states.clear()

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
	var next: SamState = states.get(key)

	if next == null:
		push_warning("SamStateMachine: Unknown state '%s'" % target_state)
		return
	if next == current_state:
		return

	var prev := current_state
	if prev:
		prev.Exit()

	current_state = next
	current_state.Enter(prev)

	_on_state_changed(prev, current_state)


func _on_state_changed(prev: SamState, now: SamState) -> void:
	var prev_name := prev.name.to_lower() if prev != null else ""
	var now_name := now.name.to_lower() if now != null else ""
	var move_name := start_move_state_name.to_lower()

	if prev_name == move_name and now_name != move_name:
		_end_cutscene_to_player_camera_async()


# Cutscene
func _start_cutscene() -> void:
	_player = _get_player()
	_player_cam = _get_player_camera()
	_cutscene_cam = _find_cutscene_camera()

	if _cutscene_cam == null:
		_freeze_player_tree(false)
		_make_player_camera_current()
		return

	_cutscene_active = true
	_cutscene_ending = false
	_restart_failsafe_if_enabled()

	_freeze_player_tree(true)

	if _player_cam:
		_cutscene_cam.global_position = _player_cam.global_position
		_cutscene_cam.zoom = _player_cam.zoom
		_player_cam_start_zoom = _player_cam.zoom
		_player_cam_start_pos = _player_cam.global_position

	_cutscene_cam.make_current()

	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_cutscene_cam, "zoom", cutscene_zoom_out, tween_time)

	var target := _find_cutscene_target()
	if target:
		_tween.tween_property(_cutscene_cam, "global_position", target.global_position, tween_time)


func _end_cutscene_to_player_camera_async() -> void:
	if not _cutscene_active or _cutscene_ending:
		return

	_cutscene_ending = true
	call_deferred("_end_cutscene_to_player_camera_impl")


func _end_cutscene_to_player_camera_impl() -> void:
	if _cutscene_cam == null:
		_make_player_camera_current()
		_freeze_player_tree(false)
		_cutscene_active = false
		_cutscene_ending = false
		_stop_failsafe()
		return

	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_cutscene_cam, "zoom", _player_cam_start_zoom, tween_time)
	_tween.tween_property(_cutscene_cam, "global_position", _player_cam_start_pos, tween_time)

	await _tween.finished

	_make_player_camera_current()
	_freeze_player_tree(false)

	_cutscene_active = false
	_cutscene_ending = false
	_stop_failsafe()


func _force_end_cutscene_immediate_to_player() -> void:
	_kill_tween()
	_make_player_camera_current()
	_freeze_player_tree(false)

	_cutscene_active = false
	_cutscene_ending = false
	_stop_failsafe()

	_demo_mode = false


func _on_cutscene_failsafe_timeout() -> void:
	if _cutscene_active:
		_force_end_cutscene_immediate_to_player()


func _restart_failsafe_if_enabled() -> void:
	if _failsafe_timer == null:
		return
	_failsafe_timer.stop()

	if cutscene_failsafe_seconds <= 0.0:
		return

	_failsafe_timer.wait_time = cutscene_failsafe_seconds
	_failsafe_timer.start()


func _stop_failsafe() -> void:
	if _failsafe_timer:
		_failsafe_timer.stop()


# Camera
func _find_cutscene_camera() -> Camera2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var direct := scene.get_node_or_null(cutscene_camera_name)
	if direct is Camera2D:
		return direct as Camera2D

	var found := _find_node_by_name(scene, cutscene_camera_name)
	if found is Camera2D:
		return found as Camera2D

	return null


func _find_cutscene_target() -> Node2D:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var direct := scene.get_node_or_null(cutscene_target_name)
	if direct is Node2D:
		return direct as Node2D

	var found := _find_node_by_name(scene, cutscene_target_name)
	if found is Node2D:
		return found as Node2D

	return null


func _get_player() -> Node:
	return get_tree().get_first_node_in_group("player")


func _get_player_camera() -> Camera2D:
	var p := _get_player()
	if p == null:
		return null

	var pc := p.get_node_or_null("Camera2D")
	if pc is Camera2D:
		return pc as Camera2D

	return _find_first_camera(p)


func _find_first_camera(root: Node) -> Camera2D:
	if root is Camera2D:
		return root as Camera2D
	for c in root.get_children():
		var res := _find_first_camera(c)
		if res:
			return res
	return null


func _make_player_camera_current() -> void:
	var pc := _get_player_camera()
	if pc:
		pc.make_current()


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null


# Freeze
func _freeze_player_tree(freeze: bool) -> void:
	if freeze:
		_player = _get_player()
		if _player == null:
			return
		if _frozen_nodes.size() > 0:
			return

		_frozen_nodes.clear()
		_collect_tree(_player)

		for item in _frozen_nodes:
			var n: Node = item[_FROZEN_NODE_KEY]
			n.process_mode = Node.PROCESS_MODE_DISABLED

		if _player is CharacterBody2D:
			(_player as CharacterBody2D).velocity = Vector2.ZERO

	else:
		for item in _frozen_nodes:
			var n: Node = item[_FROZEN_NODE_KEY]
			var mode: int = item[_FROZEN_MODE_KEY]
			if is_instance_valid(n):
				n.process_mode = mode
		_frozen_nodes.clear()


func _collect_tree(root: Node) -> void:
	_frozen_nodes.append({_FROZEN_NODE_KEY: root, _FROZEN_MODE_KEY: root.process_mode})
	for c in root.get_children():
		_collect_tree(c)


#GameState
func _get_segment_index() -> int:
	return int(GameState.puzzle_state.get(segment_index_key, 0))


func _set_segment_index(value: int) -> void:
	GameState.puzzle_state[segment_index_key] = value


func _set_failed_flag(value: bool) -> void:
	if failed_flag != "":
		GameState.puzzle_state[failed_flag] = value


# Utils 
func _find_node_by_name(root: Node, wanted: String) -> Node:
	if root.name == wanted:
		return root
	for c in root.get_children():
		var res := _find_node_by_name(c, wanted)
		if res:
			return res
	return null
