extends CharacterBody2D
class_name SAM

signal guide_started
signal guide_finished

@export var move_speed: float = 120.0

@export var guide_path_1: NodePath
@export var guide_path_2: NodePath
@export var guide_path_3: NodePath

@export var puzzle_solved_flag: String = "outside5_pillar_puzzle_solved"

@export var sam_save_id: String = "outside5_sam"

@export var pillar_puzzle_path: NodePath

@onready var state_machine: Node = $StateMachine
@onready var npc_camera: Camera2D = $NpcCamera
@onready var dialog_process: Node = $DialogProcess
@onready var interact_area: Area2D = $InteractArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pillar_sensor: Area2D = $PillarSensor

var player: Node2D = null
var guide_path_node: Path2D = null
var _prev_camera: Camera2D = null

var step: int = 1
var _player_in_range: bool = false
var _can_interact: bool = false
var _has_shown_a_path: bool = false
var _force_fail_dialog: bool = false

var facing: Vector2 = Vector2.DOWN

const ANIM_DOWN := "idle_down"
const ANIM_LEFT := "idle_left"
const ANIM_RIGHT := "idle_right"
const ANIM_UP := "idle_top"

var _highlight_enabled: bool = false

const _SAM_SAVE_PREFIX := "sam_progress_"


func _ready() -> void:
	add_to_group("sam_state_machine")

	state_machine.init(self)

	interact_area.body_entered.connect(_on_interact_body_entered)
	interact_area.body_exited.connect(_on_interact_body_exited)

	if pillar_sensor != null:
		pillar_sensor.area_entered.connect(Callable(self, "_on_pillar_sensor_area_entered"))

	guide_started.connect(Callable(self, "_on_guide_started"))
	guide_finished.connect(Callable(self, "_on_guide_finished"))

	_connect_puzzle_solved_signal()

	play_stand_idle()

	call_deferred("_load_sam_progress")


func _connect_puzzle_solved_signal() -> void:
	if pillar_puzzle_path.is_empty():
		return

	var node := get_node_or_null(pillar_puzzle_path)
	if node == null:
		return

	if node.has_signal("puzzle_solved"):
		if not node.is_connected("puzzle_solved", Callable(self, "_on_pillar_puzzle_solved")):
			node.connect("puzzle_solved", Callable(self, "_on_pillar_puzzle_solved"))


func _on_pillar_puzzle_solved() -> void:
	_try_save_after_puzzle_and_path3()


func on_player_triggered(p: Node2D) -> void:
	player = p
	step = 1
	_has_shown_a_path = false
	_force_fail_dialog = false
	_can_interact = false
	state_machine.transition_to("Approach")


func _unhandled_input(event: InputEvent) -> void:
	if not _can_interact:
		return
	if not _player_in_range:
		return

	if event.is_action_pressed("interact"):
		_start_next_dialog()


func _start_next_dialog() -> void:
	_can_interact = false

	if _has_shown_a_path and step < 3:
		step += 1

	state_machine.transition_to("Talk")


func on_guide_completed() -> void:
	_has_shown_a_path = true
	_can_interact = true
	play_stand_idle()
	state_machine.transition_to("WaitInteract")
	_try_save_after_puzzle_and_path3()


func on_dialog_finished(dialog_path: String) -> void:
	_force_fail_dialog = false

	var scene_name := _get_scene_name()

	if should_guide_after_dialog(scene_name, dialog_path):
		var idx: int = get_guide_index_for_dialog(scene_name, dialog_path)
		set_guide_index(idx)
		state_machine.transition_to("Guide")
	else:
		_can_interact = true
		play_stand_idle()
		state_machine.transition_to("WaitInteract")


func move_towards(target: Vector2) -> void:
	var dir := target - global_position

	if dir.length() < 0.001:
		stop_and_idle()
		return

	_update_facing_from_vector(dir)
	velocity = dir.normalized() * move_speed
	move_and_slide()

	play_move_anim()


func stop_and_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	play_stand_idle()


func _update_facing_from_vector(v: Vector2) -> void:
	if abs(v.x) > abs(v.y):
		facing = Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	else:
		facing = Vector2.DOWN if v.y > 0.0 else Vector2.UP


func play_move_anim() -> void:
	if anim == null or anim.sprite_frames == null:
		return

	var name := ANIM_DOWN
	if facing == Vector2.LEFT:
		name = ANIM_LEFT
	elif facing == Vector2.RIGHT:
		name = ANIM_RIGHT
	elif facing == Vector2.UP:
		name = ANIM_UP
	else:
		name = ANIM_DOWN

	if anim.sprite_frames.has_animation(name):
		if anim.animation != name or not anim.is_playing():
			anim.play(name)


func play_stand_idle() -> void:
	if anim == null or anim.sprite_frames == null:
		return

	if anim.sprite_frames.has_animation(ANIM_DOWN):
		if anim.animation != ANIM_DOWN or not anim.is_playing():
			anim.play(ANIM_DOWN)


func set_guide_index(index: int) -> void:
	var np: NodePath = NodePath("")
	match index:
		1: np = guide_path_1
		2: np = guide_path_2
		3: np = guide_path_3
		_: np = guide_path_1

	var node := get_node_or_null(np)
	guide_path_node = node as Path2D


func take_camera() -> void:
	_prev_camera = get_viewport().get_camera_2d()
	if npc_camera != null:
		npc_camera.make_current()


func restore_camera() -> void:
	if _prev_camera != null:
		_prev_camera.make_current()
	_prev_camera = null


func get_dialog_path_for_step(scene_name: String, wanted_step: int) -> String:
	if dialog_process == null:
		return ""
	if dialog_process.has_method("get_dialog_path_for_step"):
		return String(dialog_process.call("get_dialog_path_for_step", scene_name, wanted_step))
	return ""


func get_fail_dialog_path(scene_name: String) -> String:
	if dialog_process == null:
		return ""
	if dialog_process.has_method("get_fail_dialog_path"):
		return String(dialog_process.call("get_fail_dialog_path", scene_name))
	return ""


func should_guide_after_dialog(scene_name: String, dialog_path: String) -> bool:
	if dialog_process == null:
		return false
	if dialog_process.has_method("should_guide_after_dialog"):
		return bool(dialog_process.call("should_guide_after_dialog", scene_name, dialog_path))
	return false


func get_guide_index_for_dialog(scene_name: String, dialog_path: String) -> int:
	if dialog_process == null:
		return 1
	if dialog_process.has_method("get_guide_index_for_dialog"):
		return int(dialog_process.call("get_guide_index_for_dialog", scene_name, dialog_path))
	return 1


func _on_interact_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true


func _on_interact_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false


func _on_guide_started() -> void:
	_highlight_enabled = true


func _on_guide_finished() -> void:
	_highlight_enabled = false


func _on_pillar_sensor_area_entered(area: Area2D) -> void:
	if not _highlight_enabled:
		return

	var pillar := area as Pillar
	if pillar == null:
		return

	pillar.flash_hint(0.25)


func _get_scene_name() -> String:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return ""
	return String(scene.name)


func on_puzzle_failed() -> void:
	step = 1
	_force_fail_dialog = true
	_can_interact = false
	_has_shown_a_path = false
	state_machine.transition_to("Talk")


func _try_save_after_puzzle_and_path3() -> void:
	if not _is_puzzle_solved():
		return
	if step < 3:
		return
	_save_sam_progress()


func _is_puzzle_solved() -> bool:
	if puzzle_solved_flag.is_empty():
		return false
	return bool(GameState.puzzle_state.get(puzzle_solved_flag, false))


func _get_sam_save_key() -> String:
	if not sam_save_id.is_empty():
		return _SAM_SAVE_PREFIX + sam_save_id

	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return _SAM_SAVE_PREFIX + String(scene.name)


func _save_sam_progress() -> void:
	var key: String = _get_sam_save_key()
	if key.is_empty():
		return

	GameState.map_state[key] = {
		"x": global_position.x,
		"y": global_position.y,
		"step": step,
	}

	if has_node("/root/SaveSystem"):
		var ss: Node = get_node("/root/SaveSystem")
		if ss.has_method("save_game"):
			ss.call("save_game")


func _load_sam_progress() -> void:
	var key: String = _get_sam_save_key()
	if key.is_empty():
		return
	if not GameState.map_state.has(key):
		return

	var raw: Variant = GameState.map_state.get(key)
	if typeof(raw) != TYPE_DICTIONARY:
		return

	var data: Dictionary = raw

	if data.has("x") and data.has("y"):
		global_position = Vector2(float(data["x"]), float(data["y"]))

	if data.has("step"):
		step = int(data["step"])

	_can_interact = true
	play_stand_idle()
	state_machine.transition_to("WaitInteract")
