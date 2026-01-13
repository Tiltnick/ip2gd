extends Node
class_name ReplayRecorder

@export var record_interval: float = 0.05 # 20 Hz

var frames: Array[Dictionary] = []
var _accum := 0.0
var is_recording := false

func start_recording() -> void:
	frames.clear()
	_accum = 0.0
	is_recording = true

func stop_recording() -> void:
	is_recording = false

func record_tick(delta: float, player: Node2D, input_dir: Vector2) -> void:
	if not is_recording:
		return

	_accum += delta
	if _accum < record_interval:
		return
	_accum = 0.0

	frames.append({
		"pos": player.global_position,
		"input": input_dir
	})
