extends Node

# Konstanten
const LOG_DIR := "user://analytics"
const SAMPLE_INTERVAL := 0.10
const MIN_DISTANCE_PX := 2.0
const FLUSH_INTERVAL_MSEC := 2000

# Variablen
var _file: FileAccess = null
var _session_id := ""
var _accum := 0.0
var _last_pos := Vector2.ZERO
var _has_last_pos := false
var _last_flush_msec := 0


func _ready() -> void:
	# Ordner erstellen
	var err := DirAccess.make_dir_recursive_absolute(LOG_DIR)
	if err != OK:
		push_error("AnalyticsLogger: Konnte Verzeichnis nicht erstellen: %s (Fehler %d)" % [LOG_DIR, err])
		return

	# Session-ID aus Unix-Zeit und Zufallszahl (eindeutig für Bewegung + Events)
	_session_id = "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]
	var path := "%s/analytics_%s.jsonl" % [LOG_DIR, _session_id]

	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		push_error("AnalyticsLogger: Konnte Log-Datei nicht öffnen: %s (Fehler %d)" % [path, FileAccess.get_open_error()])
		return

	_last_flush_msec = Time.get_ticks_msec()
	_connect_signals()


func _connect_signals() -> void:
	# Questmanager Signale verbinden
	if has_node("/root/QuestManager"):
		QuestManager.quest_added.connect(_on_quest_added)
		QuestManager.quest_updated.connect(_on_quest_updated)
		QuestManager.quest_completed.connect(_on_quest_completed)

	# Dialogmanager Signale verbinden
	if has_node("/root/DialogManager"):
		DialogManager.dialog_started.connect(_on_dialog_started)
		DialogManager.dialog_finished.connect(_on_dialog_finished)
		DialogManager.choice_made.connect(_on_choice_made)

	# Szenenwechsel verbinden
	if has_node("/root/SceneManager"):
		SceneManager.scene_changed.connect(_on_scene_changed)

	if has_node("/root/PuzzleEvents"):
		PuzzleEvents.puzzle_started.connect(_on_puzzle_started)
		PuzzleEvents.puzzle_ended.connect(_on_puzzle_ended)


# ── Bewegungs-Tracking ────────────────────────────────────────────────────────

func track_sample(actor: CharacterBody2D, state_name: String, delta: float) -> void:
	if actor == null or _file == null:
		return

	# Dialog-State → nicht loggen
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
		"type": "movement",
		"session_id": _session_id,
		"t_msec": Time.get_ticks_msec(),
		"scene": scene_path,
		"state": state_name.to_lower(),
		"x": pos.x,
		"y": pos.y,
		"vx": vel.x,
		"vy": vel.y
	}
	_write(row)

	_last_pos = pos
	_has_last_pos = true


# ── Event-Logging ─────────────────────────────────────────────────────────────

func _on_quest_added(quest_data: Dictionary) -> void:
	_log_event("quest_added", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_updated(quest_data: Dictionary) -> void:
	_log_event("quest_updated", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_completed(quest_data: Dictionary) -> void:
	_log_event("quest_completed", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_dialog_started() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_started", {"dialog": path})


func _on_dialog_finished() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_finished", {"dialog": path})


func _on_choice_made(choice_id: String) -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_choice", {"dialog": path, "choice_id": choice_id})


func _on_scene_changed(from_path: String, to_path: String) -> void:
	_log_event("scene_changed", {"from": from_path, "to": to_path})


func _on_puzzle_started(puzzle_data: Dictionary) -> void:
	_log_event("puzzle_started", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", "")
	})


func _on_puzzle_ended(puzzle_data: Dictionary) -> void:
	_log_event("puzzle_ended", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", "")
	})


func _log_event(event: String, extra: Dictionary = {}) -> void:
	var row := {
		"type": "event",
		"session_id": _session_id,
		"t_msec": Time.get_ticks_msec(),
		"event": event,
	}
	row.merge(extra)
	_write(row)


# ── Internes Schreiben ────────────────────────────────────────────────────────

func _write(row: Dictionary) -> void:
	if _file == null:
		return
	_file.store_line(JSON.stringify(row))

	var now := Time.get_ticks_msec()
	if now - _last_flush_msec >= FLUSH_INTERVAL_MSEC:
		_file.flush()
		_last_flush_msec = now


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _file != null:
			_file.flush()
			_file.close()
