extends RefCounted
class_name GameLogger

const SCHEMA := "game_events.ndjson.v1"
const SCHEMA_VERSION := 1

var _session_id := ""
var _sink: JsonFileSink = null
var _privacy_filter: LogPrivacyFilter = null
var _source: Dictionary = {}
var _sequence := 0


func _init(session_id: String, sink: JsonFileSink, privacy_filter: LogPrivacyFilter, source: Dictionary = {}) -> void:
	_session_id = session_id
	_sink = sink
	_privacy_filter = privacy_filter
	_source = source.duplicate(true)


func is_ready() -> bool:
	return _sink != null and _sink.is_ready()


func emit_event(event_name: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	_emit("event", event_name, payload, context, legacy_fields)


func emit_log(level: String, message: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	var data := payload.duplicate(true)
	data["level"] = level
	data["message"] = message
	_emit("log", level, data, context, legacy_fields)


func emit_telemetry(metric_name: String, payload: Dictionary = {}, context: Dictionary = {}, legacy_fields: Dictionary = {}) -> void:
	_emit("telemetry", metric_name, payload, context, legacy_fields)


func close() -> void:
	if _sink != null:
		_sink.close()


func _emit(kind: String, name: String, payload: Dictionary, context: Dictionary, legacy_fields: Dictionary) -> void:
	if not is_ready():
		return

	_sequence += 1

	var row := {
		"schema": SCHEMA,
		"schema_version": SCHEMA_VERSION,
		"session_id": _session_id,
		"seq": _sequence,
		"kind": kind,
		"name": name,
		"ts_unix_msec": roundi(Time.get_unix_time_from_system() * 1000.0),
		"t_msec": Time.get_ticks_msec(),
		"source": _sanitize_dict(_source),
		"context": _sanitize_dict(context),
		"payload": _sanitize_dict(payload),
	}

	var safe_legacy := _sanitize_dict(legacy_fields)
	if safe_legacy.size() > 0:
		row.merge(safe_legacy, false)

	_sink.write_row(row)


func _sanitize_dict(data: Dictionary) -> Dictionary:
	var cloned := data.duplicate(true)
	if _privacy_filter == null:
		return cloned
	var sanitized := _privacy_filter.sanitize(cloned)
	if sanitized is Dictionary:
		return sanitized
	return {}
