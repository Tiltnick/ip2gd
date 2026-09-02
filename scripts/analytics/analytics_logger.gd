extends Node

const GameLoggerCore = preload("res://scripts/logging/core/game_logger.gd")
const JsonFileSinkCore = preload("res://scripts/logging/core/json_file_sink.gd")
const LogPrivacyFilterCore = preload("res://scripts/logging/core/privacy_filter.gd")

const LOG_DIR := "user://logs"
const LOG_FILE_PREFIX := "game"
const SAMPLE_INTERVAL := 0.10
const MIN_DISTANCE_PX := 2.0
const FLUSH_INTERVAL_MSEC := 2000

var _logger: GameLogger = null
var _sink: JsonFileSink = null
var _privacy_filter: LogPrivacyFilter = null

var _session_id := ""
var _accum := 0.0
var _last_pos := Vector2.ZERO
var _has_last_pos := false
var _session_closed := false

# Zaehler fuer die Bewegungs-Filterstatistik (Bereinigung, Kapitel 5.1):
# wie viele Abtast-Ticks (10 Hz, ausserhalb Dialog) betrachtet und wie viele
# davon tatsaechlich geschrieben wurden.
var _mv_considered := 0
var _mv_written := 0
var _mv_drop_still := 0   # verworfen: Geschwindigkeit ~ 0
var _mv_drop_near := 0    # verworfen: Weg < MIN_DISTANCE_PX

var _state_tracker: SemanticStateTracker = null
var _areas_visited: Array = []


func _ready() -> void:
	var random_suffix := ""
	var crypto := Crypto.new()
	var random_bytes := crypto.generate_random_bytes(8)
	if random_bytes.size() > 0:
		random_suffix = random_bytes.hex_encode()
	else:
		random_suffix = "%d_%d" % [randi(), randi()]
	_session_id = "%d_%s" % [Time.get_unix_time_from_system(), random_suffix]
	var path := "%s/%s_%s.jsonl" % [LOG_DIR, LOG_FILE_PREFIX, _session_id]

	_sink = JsonFileSinkCore.new(path, FLUSH_INTERVAL_MSEC)
	if _sink == null or not _sink.is_ready():
		push_error("AnalyticsLogger: Konnte JsonFileSink nicht initialisieren: %s" % path)
		return

	_privacy_filter = LogPrivacyFilterCore.new()
	_logger = GameLoggerCore.new(_session_id, _sink, _privacy_filter, {
		"adapter": "GodotAnalyticsAdapter",
		"engine": "godot",
		"game": "BloomOfMemory"
	})

	_state_tracker = SemanticStateTracker.new()
	_state_tracker.attach_logger(self)

	_connect_signals()
	_log_session_started()


func _connect_signals() -> void:
	if has_node("/root/QuestManager"):
		QuestManager.quest_added.connect(_on_quest_added)
		QuestManager.quest_updated.connect(_on_quest_updated)
		QuestManager.quest_completed.connect(_on_quest_completed)

	if has_node("/root/DialogManager"):
		DialogManager.dialog_started.connect(_on_dialog_started)
		DialogManager.dialog_finished.connect(_on_dialog_finished)
		DialogManager.choice_made.connect(_on_choice_made)

	if has_node("/root/SceneManager"):
		SceneManager.scene_changed.connect(_on_scene_changed)

	if has_node("/root/PuzzleEvents"):
		PuzzleEvents.puzzle_started.connect(_on_puzzle_started)
		PuzzleEvents.puzzle_ended.connect(_on_puzzle_ended)


func emit_event(event_name: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	if _logger == null:
		return
	_logger.emit_event(event_name, payload, context, legacy_fields)


func emit_log(level: String, message: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	if _logger == null:
		return
	_logger.emit_log(level, message, payload, context, legacy_fields)


func emit_telemetry(metric_name: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	if _logger == null:
		return
	_logger.emit_telemetry(metric_name, payload, context, legacy_fields)


func track_sample(actor: CharacterBody2D, state_name: String, delta: float) -> void:
	if actor == null or _logger == null:
		return

	if state_name.to_lower() == "dialog":
		return

	_accum += delta
	if _accum < SAMPLE_INTERVAL:
		return
	_accum = 0.0
	_mv_considered += 1

	var pos: Vector2 = actor.global_position
	var vel: Vector2 = actor.velocity

	if vel.length() < 0.01:
		_mv_drop_still += 1
		return

	if _has_last_pos and pos.distance_to(_last_pos) < MIN_DISTANCE_PX:
		_mv_drop_near += 1
		return

	var current_scene := get_tree().current_scene
	var scene_path := ""
	if current_scene != null:
		scene_path = current_scene.scene_file_path

	var payload := {
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
	}
	_emit_adapter_event("telemetry", "movement_sample", payload, "movement", "")
	_mv_written += 1

	_last_pos = pos
	_has_last_pos = true


func _on_quest_added(quest_data: Dictionary) -> void:
	_log_event("quest_added", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})
	_log_semantic_snapshot("quest_added")


func _on_quest_updated(quest_data: Dictionary) -> void:
	_log_event("quest_updated", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})


func _on_quest_completed(quest_data: Dictionary) -> void:
	_log_event("quest_completed", {"quest_id": quest_data.get("id", ""), "title": quest_data.get("title", "")})
	_log_semantic_snapshot("quest_completed")


func _on_dialog_started() -> void:
	var path = DialogManager.current_dialog_path
	_log_event("dialog_started", {"dialog": path})


func _on_dialog_finished() -> void:
	var path = DialogManager.current_dialog_path
	_log_event("dialog_finished", {"dialog": path})
	_log_semantic_snapshot("dialog_finished")


func _on_choice_made(choice_id: String) -> void:
	var path = DialogManager.current_dialog_path
	_log_event("dialog_choice", {"dialog": path, "choice_id": choice_id})


func _on_scene_changed(from_path: String, to_path: String) -> void:
	_emit_adapter_event("event", "scene_changed", {
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
	}, "scene_changed", "scene_changed")
	_log_semantic_snapshot("scene_changed")


func _on_puzzle_started(puzzle_data: Dictionary) -> void:
	_emit_adapter_event("event", "puzzle_started", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", ""),
		"metadata": {
			"puzzle_id": puzzle_data.get("id", ""),
			"title": puzzle_data.get("title", "")
		}
	}, "puzzle_started", "puzzle_started")
	_log_semantic_snapshot("puzzle_started")


func _on_puzzle_ended(puzzle_data: Dictionary) -> void:
	_emit_adapter_event("event", "puzzle_solved", {
		"puzzle_id": puzzle_data.get("id", ""),
		"title": puzzle_data.get("title", ""),
		"result": puzzle_data.get("result", "closed"),
		"metadata": {
			"puzzle_id": puzzle_data.get("id", ""),
			"title": puzzle_data.get("title", ""),
			"result": puzzle_data.get("result", "closed")
		}
	}, "puzzle_ended", "puzzle_ended")
	_log_semantic_snapshot("puzzle_ended")


func _log_event(event: String, extra: Dictionary = {}) -> void:
	_emit_adapter_event("event", event, extra, "event", event)


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
	_emit_adapter_event("event", "session_started", {}, "event", "session_started")


func _log_session_ended() -> void:
	if _session_closed:
		return
	_session_closed = true
	_log_movement_filter_stats()
	_emit_adapter_event("event", "session_ended", {}, "event", "session_ended")


func _log_movement_filter_stats() -> void:
	# Bereinigungs-Kennzahlen der Bewegungsdaten (Kapitel 5.1): wie viele
	# Abtast-Ticks betrachtet und wie viele nach den Filtern geschrieben wurden.
	_emit_adapter_event("telemetry", "movement_filter_stats", {
		"considered": _mv_considered,
		"written": _mv_written,
		"dropped_still": _mv_drop_still,
		"dropped_near": _mv_drop_near,
		"min_distance_px": MIN_DISTANCE_PX,
		"sample_interval_s": SAMPLE_INTERVAL,
		"metadata": {
			"considered": _mv_considered,
			"written": _mv_written,
			"dropped_still": _mv_drop_still,
			"dropped_near": _mv_drop_near
		}
	}, "telemetry", "")


func log_semantic(snapshot: Dictionary, context: String = "") -> void:
	_emit_adapter_event("telemetry", "semantic_snapshot", {
		"context": context,
		"state": snapshot,
		"metadata": {
			"context": context
		}
	}, "semantic", "")


func _log_semantic_snapshot(context: String = "") -> void:
	var snapshot := _build_semantic_snapshot()
	log_semantic(snapshot, context)


func _build_semantic_snapshot() -> Dictionary:
	var area_path: String = GameState.current_area_path
	var current_area := _scene_name_from_path(area_path)

	if current_area != "" and not _areas_visited.has(current_area):
		_areas_visited.append(current_area)

	var picked: Array = GameState.picked_items.duplicate()

	var map_collected: bool = (
		picked.has("minimap_item")
		or hotbarglobal.has_item("map")
	)

	var diary_collected: bool = bool(GameState.puzzle_state.get("spaceship_diary", false))

	var shovel_collected: bool = (
		picked.has("shovel_1")
		or hotbarglobal.has_item("shovel")
	)

	var stone_puzzle_solved: bool = bool(GameState.puzzle_state.get("stone_puzzle", false))
	var color_code_solved: bool = bool(GameState.puzzle_state.get("color_code_2151", false))
	var statue_puzzle_solved: bool = bool(GameState.puzzle_state.get("statue_puzzle", false))
	var temple_puzzle_solved: bool = bool(GameState.puzzle_state.get("outside5_pillar_puzzle_solved", false))
	var all_tripods_interacted: bool = bool(GameState.puzzle_state.get("all_tripods_interacted", false))
	var treasure_chest_solved: bool = bool(GameState.puzzle_state.get("treasure_chest_code", false))

	var mr_blob_dialog_stage := _compute_blob_dialog_stage()

	var active_quests: Array = []
	var completed_quests_list: Array = []
	for qid in QuestManager.current_quests.keys():
		active_quests.append(qid)
	for qid in QuestManager.completed_quests.keys():
		completed_quests_list.append(qid)

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


func _scene_name_from_path(scene_path: String) -> String:
	if scene_path == "":
		return ""
	return scene_path.get_file().get_basename()


func _emit_adapter_event(kind: String, event_name: String, extra: Dictionary, legacy_type: String, legacy_event: String) -> void:
	if _logger == null:
		return

	var legacy_row := _build_row(event_name, legacy_type, legacy_event, extra)
	var context := {
		"room": legacy_row.get("room", ""),
		"scene": legacy_row.get("scene", ""),
		"position": legacy_row.get("position", {})
	}

	match kind:
		"telemetry":
			emit_telemetry(event_name, extra, context, legacy_row)
		"log":
			var level := String(extra.get("level", "info"))
			var message := String(extra.get("message", ""))
			emit_log(level, message, extra, context, legacy_row)
		"event":
			emit_event(event_name, extra, context, legacy_row)
		_:
			emit_event(event_name, extra, context, legacy_row)


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
	if position.size() > 0:
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_log_session_ended()
		if _logger != null:
			_logger.close()
