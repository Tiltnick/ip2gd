extends Node

const LOG_DIR := "user://analytics"
const SAMPLE_INTERVAL := 0.10
const MIN_DISTANCE_PX := 2.0
const FLUSH_INTERVAL_MSEC := 2000

var _file: FileAccess = null
var _session_id := ""
var _accum := 0.0
var _last_pos := Vector2.ZERO
var _has_last_pos := false
var _last_flush_msec := 0

func _ready() -> void:
	DirAccess.make_dir_absolute(LOG_DIR)

	_session_id = str(Time.get_unix_time_from_system())
	var path := "%s/movement_%s.jsonl" % [LOG_DIR, _session_id]

	_file = FileAccess.open(path, FileAccess.WRITE)
	_last_flush_msec = Time.get_ticks_msec()

func track_sample(actor: CharacterBody2D, state_name: String, delta: float) -> void:
	if actor == null or _file == null:
		return

	if state_name.to_lower() == "dialog":
		return

	_accum += delta
	if _accum < SAMPLE_INTERVAL:
		return
	_accum = 0.0

	var pos: Vector2 = actor.global_position
	var vel: Vector2 = actor.velocity

	if vel.length() < 0.01:
		return

	if _has_last_pos and pos.distance_to(_last_pos) < MIN_DISTANCE_PX:
		return

	var current_scene := get_tree().current_scene
	var scene_path := ""
	if current_scene != null:
		scene_path = current_scene.scene_file_path

	var row := {
		"session_id": _session_id,
		"t_msec": Time.get_ticks_msec(),
		"scene": scene_path,
		"state": state_name.to_lower(),
		"x": pos.x,
		"y": pos.y,
		"vx": vel.x,
		"vy": vel.y
	}

	_file.store_line(JSON.stringify(row))

	_last_pos = pos
	_has_last_pos = true

	var now := Time.get_ticks_msec()
	if now - _last_flush_msec >= FLUSH_INTERVAL_MSEC:
		_file.flush()
		_last_flush_msec = now

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _file != null:
			_file.flush()
			_file.close()
