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
	# Ordner erstellen falls noch nicht vorhanden
	DirAccess.make_dir_absolute(LOG_DIR)

	# Session Id für eindeutige Kennung
	_session_id = str(Time.get_unix_time_from_system())
	var path := "%s/movement_%s.jsonl" % [LOG_DIR, _session_id]

	_file = FileAccess.open(path, FileAccess.WRITE)
	_last_flush_msec = Time.get_ticks_msec()

func track_sample(actor: CharacterBody2D, state_name: String, delta: float) -> void:
	# actor = Spieler
	if actor == null or _file == null:
		return

	# state = dialog -> nichts loggen
	if state_name.to_lower() == "dialog":
		return

	# Vergangene Zeit aufsummieren
	_accum += delta
	if _accum < SAMPLE_INTERVAL:
		return
	_accum = 0.0

	# Position und Geschwindigkeit des Spielers
	var pos: Vector2 = actor.global_position
	var vel: Vector2 = actor.velocity

	# Geschwindigkeit < 0.01 == nicht loggen
	if vel.length() < 0.01:
		return

	# Fast identische Einträge ignorieren
	if _has_last_pos and pos.distance_to(_last_pos) < MIN_DISTANCE_PX:
		return

	# Szene erkennen und speichern
	var current_scene := get_tree().current_scene
	var scene_path := ""
	if current_scene != null:
		scene_path = current_scene.scene_file_path

	# Dictionary erzeugen
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

	# Speichern als JSON
	_file.store_line(JSON.stringify(row))

	# Letze Positon speichern und true setzen
	_last_pos = pos
	_has_last_pos = true

	# WRITE -> wichtig für Abstürze etc.
	var now := Time.get_ticks_msec()
	if now - _last_flush_msec >= FLUSH_INTERVAL_MSEC:
		_file.flush()
		_last_flush_msec = now

# Reaktion auf das Engine Fenster 
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _file != null:
			_file.flush()
			_file.close()
