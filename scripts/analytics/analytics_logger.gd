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
var _session_closed := false

# Semantischer Zustands-Tracker
var _state_tracker: SemanticStateTracker = null

# Akkumuliert besuchte Bereiche über die gesamte Session
var _areas_visited: Array = []


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

	# SemanticStateTracker initialisieren
	_state_tracker = SemanticStateTracker.new()
	_state_tracker.attach_logger(self)

	_connect_signals()
	_log_session_started()


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

	var row := _build_row("movement_sample", "movement", "", {
		"scene": scene_path,
		"state": state_name.to_lower(),
		"x": pos.x,
		"y": pos.y,
		"vx": vel.x,
		"vy": vel.y,
		"position": {
			"x": pos.x,
			"y": pos.y
		},
		"metadata": {
			"state": state_name.to_lower()
		}
	})
	_write(row)

	_last_pos = pos
	_has_last_pos = true


# ── Event-Logging ─────────────────────────────────────────────────────────────

func _on_quest_added(quest_data: Dictionary) -> void:
	_log_event("quest_added", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})
	_log_semantic_snapshot("quest_added")


func _on_quest_updated(quest_data: Dictionary) -> void:
	_log_event("quest_updated", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_completed(quest_data: Dictionary) -> void:
	_log_event("quest_completed", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})
	_log_semantic_snapshot("quest_completed")


func _on_dialog_started() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_started", {"dialog": path})


func _on_dialog_finished() -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_finished", {"dialog": path})
	_log_semantic_snapshot("dialog_finished")


func _on_choice_made(choice_id: String) -> void:
	var path := DialogManager.current_dialog_path
	_log_event("dialog_choice", {"dialog": path, "choice_id": choice_id})


func _on_scene_changed(from_path: String, to_path: String) -> void:
	var row := _build_row("scene_changed", "scene_changed", "scene_changed", {
		"from": from_path,
		"to": to_path,
		"from_room": from_path,
		"to_room": to_path,
		"room": to_path,
		"scene": to_path,
		"metadata": {
			"from_room": from_path,
			"to_room": to_path
		}
	})
	_write(row)
	_log_semantic_snapshot("scene_changed")


func _on_puzzle_started(puzzle_data: Dictionary) -> void:
	var row := _build_row("puzzle_started", "puzzle_started", "puzzle_started", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", ""),
		"metadata": {
			"puzzle_id": puzzle_data.get("id", ""),
			"title": puzzle_data.get("title", "")
		}
	})
	_write(row)
	_log_semantic_snapshot("puzzle_started")


func _on_puzzle_ended(puzzle_data: Dictionary) -> void:
	var row := _build_row("puzzle_solved", "puzzle_ended", "puzzle_ended", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", ""),
		"result": puzzle_data.get("result", "closed"),
		"metadata": {
			"puzzle_id": puzzle_data.get("id", ""),
			"title": puzzle_data.get("title", ""),
			"result": puzzle_data.get("result", "closed")
		}
	})
	_write(row)
	_log_semantic_snapshot("puzzle_ended")


func _log_event(event: String, extra: Dictionary = {}) -> void:
	var row := _build_row(event, "event", event, extra)
	_write(row)


func log_interaction(interaction_id: String, extra: Dictionary = {}) -> void:
	var payload := extra.duplicate(true)
	payload["interaction_id"] = interaction_id
	_log_event("interaction", payload)


func log_item_collected(item_id: String, extra: Dictionary = {}) -> void:
	var payload := extra.duplicate(true)
	payload["item_id"] = item_id
	_log_event("item_collected", payload)
	_log_semantic_snapshot("item_collected")


func log_checkpoint_reached(checkpoint_id: String, extra: Dictionary = {}) -> void:
	var payload := extra.duplicate(true)
	payload["checkpoint_id"] = checkpoint_id
	_log_event("checkpoint_reached", payload)


func log_game_finished(extra: Dictionary = {}) -> void:
	_log_event("game_finished", extra)


func _log_session_started() -> void:
	_write(_build_row("session_started", "event", "session_started", {}))


func _log_session_ended() -> void:
	if _session_closed:
		return
	_session_closed = true
	_write(_build_row("session_ended", "event", "session_ended", {}))


# ── Semantisches Logging ──────────────────────────────────────────────────────

## Loggt einen semantischen Zustandssnapshot. Wird nach jedem bedeutungsvollen
## Event aufgerufen, um die Zustandsfolge für Playtracer zu rekonstruieren.
func log_semantic(snapshot: Dictionary, context: String = "") -> void:
	var row := _build_row("semantic_snapshot", "semantic", "", {
		"context": context,
		"state": snapshot,
		"metadata": {
			"context": context
		}
	})
	_write(row)


## Baut einen semantischen Snapshot aus dem aktuellen Spielzustand und loggt ihn.
func _log_semantic_snapshot(context: String = "") -> void:
	var snapshot := _build_semantic_snapshot()
	log_semantic(snapshot, context)


## Leitet semantische Features aus dem rohen Spielzustand ab (GameState, QuestManager,
## hotbarglobal). Konzeptuell gleiche Situationen erzeugen dieselben Feature-Werte.
func _build_semantic_snapshot() -> Dictionary:
	# ── Navigation ──────────────────────────────────────────────────────────
	var area_path: String = GameState.current_area_path
	var current_area := _scene_name_from_path(area_path)

	# areas_visited akkumulieren: Persistent-Feld in diesem Logger
	if current_area != "" and not _areas_visited.has(current_area):
		_areas_visited.append(current_area)

	# ── Items ────────────────────────────────────────────────────────────────
	var picked: Array = GameState.picked_items.duplicate()

	# "map_collected": Karte eingesammelt
	var map_collected: bool = (
		picked.has("minimap_item")
		or hotbarglobal.has_item("map")
	)

	# "diary_collected": Tagebuch eingesammelt
	var diary_collected: bool = bool(GameState.puzzle_state.get("spaceship_diary", false))

	# "shovel_collected": Schaufel eingesammelt
	var shovel_collected: bool = (
		picked.has("shovel_1")
		or hotbarglobal.has_item("shovel")
	)

	# Rätsel (Puzzle)
	var stone_puzzle_solved: bool = bool(GameState.puzzle_state.get("stone_puzzle", false))
	var color_code_solved: bool = bool(GameState.puzzle_state.get("color_code_2151", false))
	var statue_puzzle_solved: bool = bool(GameState.puzzle_state.get("statue_puzzle", false))
	var temple_puzzle_solved: bool = bool(GameState.puzzle_state.get("outside5_pillar_puzzle_solved", false))
	var all_tripods_interacted: bool = bool(GameState.puzzle_state.get("all_tripods_interacted", false))
	var treasure_chest_solved: bool = bool(GameState.puzzle_state.get("treasure_chest_code", false))

	# Mr. Blob Dialogstufe
	# Jede Stufe entspricht einem abgeschlossenen Dialog-Schritt.
	var mr_blob_dialog_stage := _compute_blob_dialog_stage()

	# Quests
	var active_quests: Array = []
	var completed_quests_list: Array = []
	for qid in QuestManager.current_quests.keys():
		active_quests.append(qid)
	for qid in QuestManager.completed_quests.keys():
		completed_quests_list.append(qid)

	# Tutorial
	var tutorial_done: bool = GameState.tutorial_done

	return {
		"current_area": current_area,
		"areas_visited": _areas_visited.duplicate(),
		"map_collected": map_collected,
		"diary_collected": diary_collected,
		"shovel_collected": shovel_collected,
		"items_collected": picked,
		"stone_puzzle_solved": stone_puzzle_solved,
		"color_code_solved": color_code_solved,
		"statue_puzzle_solved": statue_puzzle_solved,
		"temple_puzzle_solved": temple_puzzle_solved,
		"all_tripods_interacted": all_tripods_interacted,
		"treasure_chest_solved": treasure_chest_solved,
		"mr_blob_dialog_stage": mr_blob_dialog_stage,
		"active_quests": active_quests,
		"completed_quests": completed_quests_list,
		"tutorial_done": tutorial_done,
	}


# Aktuelle Dialogstufe aus Flags ableiten
# Höhere Stages bedeuten fortgeschritteneren Spielfortschritt.
func _compute_blob_dialog_stage() -> int:
	var ps: Dictionary = GameState.puzzle_state
	if bool(ps.get("blob_flower_done", false)):
		return 6
	if bool(ps.get("blob_cave_done", false)):
		return 5
	if bool(ps.get("blob_revelation_done", false)):
		return 4
	if bool(ps.get("blob_clue_done", false)):
		return 3
	if bool(ps.get("blob_intro_done", false)):
		return 2
	if bool(ps.get("outside1_done", false)):
		return 1
	return 0


# Extrahiert den lesbaren Szenennamen aus einem res://-Pfad.
# z.B. "res://scenes/maps/Outside_2/outside_2.tscn" -> "outside_2"
func _scene_name_from_path(scene_path: String) -> String:
	if scene_path == "":
		return ""
	return scene_path.get_file().get_basename()


# Internes Schreiben

func _build_row(event_type: String, legacy_type: String, legacy_event: String, extra: Dictionary) -> Dictionary:
	var room := _current_room_path()
	var position := _current_player_position()
	var row := {
		"session_id": _session_id,
		"t_msec": Time.get_ticks_msec(),
		"event_type": event_type,
		"room": room,
		"metadata": {}
	}
	if legacy_type != "":
		row["type"] = legacy_type
	if legacy_event != "":
		row["event"] = legacy_event
	if room != "":
		row["scene"] = room
	if not position.is_empty():
		row["position"] = position
		row["x"] = position["x"]
		row["y"] = position["y"]

	var payload := extra.duplicate(true)
	if payload.has("metadata") and payload["metadata"] is Dictionary:
		row["metadata"] = payload["metadata"].duplicate(true)
		payload.erase("metadata")
	row.merge(payload, true)
	return row


func _current_room_path() -> String:
	if GameState.current_area_path != "":
		return GameState.current_area_path
	var current_scene := get_tree().current_scene
	if current_scene != null:
		return current_scene.scene_file_path
	return ""


func _current_player_position() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return {}
	if not (player is Node2D):
		return {}
	var pos: Vector2 = (player as Node2D).global_position
	return {
		"x": pos.x,
		"y": pos.y
	}

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
			_log_session_ended()
			_file.flush()
			_file.close()
