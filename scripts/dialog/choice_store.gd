extends Node
class_name ChoiceStore

# Wo die Entscheidungen gespeichert werden sollen
@export var path: String = "user://choices.json"


func add_choice_id(choice_id: String) -> void:
	var data: Dictionary = {}

	# Falls Datei existiert → laden
	if FileAccess.file_exists(path):
		var content: String = FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed as Dictionary

	# decisions-Array vorbereiten
	var decisions_array: Array = []
	if data.has("decisions"):
		decisions_array = data["decisions"] as Array

	# Entscheidung hinzufügen
	decisions_array.append(choice_id)
	data["decisions"] = decisions_array

	# JSON zurück speichern
	var json_text: String = JSON.stringify(data, "\t")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()


func get_decisions() -> Array:
	var data: Dictionary = {}

	if FileAccess.file_exists(path):
		var content: String = FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed as Dictionary

	if data.has("decisions"):
		return data["decisions"] as Array

	return []
