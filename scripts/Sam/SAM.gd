extends CharacterBody2D
class_name SAM

signal guide_started
signal guide_finished

@export var move_speed: float = 120.0

@export var guide_path_1: NodePath
@export var guide_path_2: NodePath
@export var guide_path_3: NodePath

@onready var state_machine = $StateMachine
@onready var npc_camera: Camera2D = $NpcCamera
@onready var dialog_process: Node = $DialogProcess
@onready var interact_area: Area2D = $InteractArea

var player: Node2D = null
var guide_path_node: Path2D = null
var _prev_camera: Camera2D = null

# Step 1..3 = welcher Dialog/Weg als Nächstes
var step: int = 1

var _player_in_range: bool = false
var _can_interact: bool = false

# Wird true sobald SAM mindestens 1x einen Weg gezeigt hat
var _has_shown_a_path: bool = false


func _ready() -> void:
	state_machine.init(self)

	interact_area.body_entered.connect(_on_interact_body_entered)
	interact_area.body_exited.connect(_on_interact_body_exited)


func on_player_triggered(p: Node2D) -> void:
	player = p

	# Optional: falls du speicherst/lädst, resync über Flags:
	_sync_step_from_flags()

	_can_interact = false
	_has_shown_a_path = false
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

	# WICHTIG: Nach dem ersten gezeigten Weg soll beim nächsten Reden step hochgehen
	if _has_shown_a_path and step < 3:
		step += 1

	# Wenn du nach Step 3 NICHT nochmal reden willst:
	# if _has_shown_a_path and step >= 3:
	#     state_machine.transition_to("Idle")
	#     return

	state_machine.transition_to("Talk")


func on_guide_completed() -> void:
	# SAM ist fertig mit “Weg zeigen” -> jetzt läuft Spieler selbst
	_has_shown_a_path = true
	_can_interact = true
	state_machine.transition_to("WaitInteract")


func on_dialog_finished(dialog_path: String) -> void:
	var scene_name := _get_scene_name()

	if should_guide_after_dialog(scene_name, dialog_path):
		var idx: int = get_guide_index_for_dialog(scene_name, dialog_path)
		set_guide_index(idx)
		state_machine.transition_to("Guide")
	else:
		_can_interact = true
		state_machine.transition_to("WaitInteract")


func move_towards(target: Vector2) -> void:
	var dir := target - global_position
	if dir.length() < 0.001:
		velocity = Vector2.ZERO
	else:
		velocity = dir.normalized() * move_speed
	move_and_slide()


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


func _get_scene_name() -> String:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return ""
	return String(scene.name)


func _sync_step_from_flags() -> void:
	# Wenn Dialog1 done -> nächster ist Schritt 2, usw.
	if bool(GameState.puzzle_state.get("sam_dialog_3_done", false)):
		step = 3
	elif bool(GameState.puzzle_state.get("sam_dialog_2_done", false)):
		step = 2
	elif bool(GameState.puzzle_state.get("sam_dialog_1_done", false)):
		step = 1 # du kannst hier auch 2 setzen, wenn du nach Reload direkt Dialog2 willst
	else:
		step = 1


func on_puzzle_failed() -> void:
	step = 1
	_has_shown_a_path = false
	_can_interact = false
	state_machine.transition_to("Talk")
