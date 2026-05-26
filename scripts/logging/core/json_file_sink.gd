extends RefCounted
class_name JsonFileSink

const DEFAULT_FLUSH_INTERVAL_MSEC := 2000

var _file: FileAccess = null
var _path := ""
var _flush_interval_msec := DEFAULT_FLUSH_INTERVAL_MSEC
var _last_flush_msec := 0


func _init(path: String, flush_interval_msec: int = DEFAULT_FLUSH_INTERVAL_MSEC) -> void:
	_path = path
	_flush_interval_msec = max(100, flush_interval_msec)
	_open_file()


func is_ready() -> bool:
	return _file != null


func write_row(row: Dictionary) -> void:
	if _file == null:
		return
	_file.store_line(JSON.stringify(row))
	var now := Time.get_ticks_msec()
	if now - _last_flush_msec >= _flush_interval_msec:
		flush()


func flush() -> void:
	if _file == null:
		return
	_file.flush()
	_last_flush_msec = Time.get_ticks_msec()


func close() -> void:
	if _file == null:
		return
	flush()
	_file.close()
	_file = null


func _open_file() -> void:
	var dir_path := _path.get_base_dir()
	var err := DirAccess.make_dir_recursive_absolute(dir_path)
	if err != OK:
		push_error("JsonFileSink: Konnte Verzeichnis nicht erstellen: %s (Fehler %d)" % [dir_path, err])
		return

	_file = FileAccess.open(_path, FileAccess.WRITE)
	if _file == null:
		push_error("JsonFileSink: Konnte Datei nicht öffnen: %s (Fehler %d)" % [_path, FileAccess.get_open_error()])
		return

	_last_flush_msec = Time.get_ticks_msec()
