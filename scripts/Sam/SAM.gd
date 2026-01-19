extends CharacterBody2D
class_name SAM

signal guide_started
signal guide_finished

@export var move_speed: float = 120.0

@export var guide_path_1: NodePath
@export var guide_path_2: NodePath
@export var guide_path_3: NodePath

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


func _ready() -> void:
	add_to_group("sam_state_machine")

	state_machine.init(self)

	interact_area.body_entered.connect(_on_interact_body_entered)
	interact_area.body_exited.connect(_on_interact_body_exited)

	if pillar_sensor != null:
		pillar_sensor.area_entered.connect(Callable(self, "_on_pillar_sensor_area_entered"))

	guide_started.connect(Callable(self, "_on_guide_started"))
	guide_finished.connect(Callable(self, "_on_guide_finished"))

	play_stand_idle()


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
	return String(dialog_process.call("get_dialog_path_for_step", scene_name, wanted_step))


func get_fail_dialog_path(scene_name: String) -> String:
	return String(dialog_process.call("get_fail_dialog_path", scene_name))


func should_guide_after_dialog(scene_name: String, dialog_path: String) -> bool:
	return bool(dialog_process.call("should_guide_after_dialog", scene_name, dialog_path))


func get_guide_index_for_dialog(scene_name: String, dialog_path: String) -> int:
	return int(dialog_process.call("get_guide_index_for_dialog", scene_name, dialog_path))


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
