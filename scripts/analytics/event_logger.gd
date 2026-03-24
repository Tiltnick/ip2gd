extends Node

# Konstanten
const LOG_DIR := "user://analytics"
const FLUSH_INTERVAL_MSEC := 2000

# Variablen
var _file: FileAccess = null
var _session_id := ""
var _last_flush_msec := 0


func _ready() -> void:
	# Ordner erstellen
	var err := DirAccess.make_dir_recursive_absolute(LOG_DIR)
	if err != OK:
		push_error("EventLogger: Konnte Verzeichnis nicht erstellen: %s (Fehler %d)" % [LOG_DIR, err])
		return

	# Session Id erzeugen aus Unix-Zeit und Zufallszahl
	_session_id = "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]
	var path := "%s/events_%s.jsonl" % [LOG_DIR, _session_id]

	# File öffnen für WRITE
	_file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		push_error("EventLogger: Konnte Log-Datei nicht öffnen: %s (Fehler %d)" % [path, FileAccess.get_open_error()])
		return

	# Laufzeit speichern
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

# Quest Callbacks added, updated, completed
func _on_quest_added(quest_data: Dictionary) -> void:
	_log_event("quest_added", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_updated(quest_data: Dictionary) -> void:
	_log_event("quest_updated", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_completed(quest_data: Dictionary) -> void:
	_log_event("quest_completed", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


# Dialog-Callbacks started, finished, choice made
func _on_dialog_started() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_started", {"dialog": path})


func _on_dialog_finished() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_finished", {"dialog": path})


func _on_choice_made(choice_id: String) -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_choice", {"dialog": path, "choice_id": choice_id})


# Szenenwechsel
func _on_scene_changed(from_path: String, to_path: String) -> void:
	_log_event("scene_changed", {"from": from_path, "to": to_path})


func _log_event(event: String, extra: Dictionary = {}) -> void:
	if _file == null:
		return

	# Grund-Datensatz
	var row := {
		"session_id": _session_id,
		"t_msec": Time.get_ticks_msec(),
		"event": event,
	}
	row.merge(extra)

	# In Datei schreiben
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
