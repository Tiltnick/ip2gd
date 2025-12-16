extends Control

var all_entries: Dictionary = {}
var unlocked_entries: Array[String] = []
signal entry_unlocked

func _ready() -> void:
	load_diary_data()
	unlock_entry("entry_1")
	unlock_entry("entry_2")
	

func load_diary_data():
	var file = FileAccess.open("res://diaryText/diary.json", FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.has("entries"):
		all_entries = parsed["entries"]
	else: 
		print("Fehler beim Laden")

func unlock_entry(id: String):
	if not unlocked_entries.has(id) and all_entries.has(id):
		unlocked_entries.append(id)
		emit_signal("entry_unlocked")

func is_unlocked(id: String) -> bool:
	return unlocked_entries.has(id)

func get_header(id: String) -> String:
	return all_entries[id].get("header", "")

func get_text(id: String) -> String:
	
	return all_entries[id].get("text_de", "")
