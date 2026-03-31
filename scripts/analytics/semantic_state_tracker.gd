class_name SemanticStateTracker
extends RefCounted

# Aktueller semantischer Zustand als Dictionary
var _state: Dictionary = {}

# Referenz auf den AnalyticsLogger (wird über attach_logger gesetzt)
var _logger: Node = null

# Gespeicherte Snapshots (für spätere State-Graphen-Rekonstruktion)
var _snapshot_history: Array = []


# ── Logger-Bindung ────────────────────────────────────────────────────────────

## Bindet einen Logger, der log_semantic(snapshot, context) implementiert.
func attach_logger(logger: Node) -> void:
	_logger = logger


# ── Initialisierung ───────────────────────────────────────────────────────────

## Setzt den initialen Zustand. Vorhandene Werte werden überschrieben.
func init_state(initial: Dictionary) -> void:
	_state = initial.duplicate(true)


# ── Zustand ändern ────────────────────────────────────────────────────────────

## Setzt ein Boolean-Flag (z.B. map_collected = true).
func set_flag(key: String, value: bool) -> void:
	_state[key] = value


## Setzt einen beliebigen Wert (z.B. current_area = "Outside_2").
func set_value(key: String, value: Variant) -> void:
	_state[key] = value


## Erhöht einen Zähler um den angegebenen Wert (z.B. diary_used_count += 1).
func increment(key: String, by: int = 1) -> void:
	_state[key] = int(_state.get(key, 0)) + by


## Fügt einen Eintrag eindeutig zu einer Liste hinzu (z.B. areas_visited += "Outside_2").
func add_to_set(key: String, item: Variant) -> void:
	if not _state.has(key) or typeof(_state[key]) != TYPE_ARRAY:
		_state[key] = []
	var arr: Array = _state[key]
	if not arr.has(item):
		arr.append(item)


# ── Snapshot ──────────────────────────────────────────────────────────────────

## Gibt eine Kopie des aktuellen Zustands zurück.
func get_snapshot() -> Dictionary:
	return _state.duplicate(true)


## Speichert einen Snapshot in der lokalen History (für spätere Analyse).
func save_snapshot() -> void:
	_snapshot_history.append(_state.duplicate(true))


## Loggt den aktuellen Zustand als semantischen Snapshot über den gebundenen Logger.
## context beschreibt, was den Snapshot ausgelöst hat (z.B. "scene_changed").
func log_snapshot(context: String = "") -> void:
	if _logger == null or not _logger.has_method("log_semantic"):
		return
	_logger.log_semantic(get_snapshot(), context)
