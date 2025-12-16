extends Node

const DEFAULT_LANGUAGE := "automatic"
var language_code: String = DEFAULT_LANGUAGE


func _ready() -> void:
	_load_language()
	_apply_language()


func set_language(code: String) -> void:
	language_code = code
	_apply_language()
	_save_language()


func get_language() -> String:
	return language_code


func get_effective_locale() -> String:
	if language_code == "automatic":
		return OS.get_locale_language()
	return language_code


func apply_language() -> void:
	_apply_language()


func _apply_language() -> void:
	TranslationServer.set_locale(get_effective_locale())


func _save_language() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("general", "language", language_code)
	cfg.save("user://settings.cfg")


func _load_language() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://settings.cfg")
	if err == OK:
		language_code = str(cfg.get_value("general", "language", DEFAULT_LANGUAGE))
	else:
		language_code = DEFAULT_LANGUAGE
