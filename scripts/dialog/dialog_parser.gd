extends Node
class_name DialogParser

var data: Dictionary = {}
var portraits: Dictionary = {}   # <--- neu

# Name of the current section inside the JSON (dialog starts with "sections" and ends with "end")
var current_node: String = ""

# Index of the current line within the node's "lines" array
var line_index: int = 0

func load_json(path: String) -> bool:
	data = {}
	portraits = {}
	current_node = ""
	line_index = 0

	# Read the JSON file as a string and parse it
	var json: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(json)
	if typeof(parsed) != TYPE_DICTIONARY:
		# %s path will be print out as a string so you can see which json is broken
		push_error("Invalid JSON: %s" % path)
		return false

	var dict: Dictionary = parsed as Dictionary

	# Characters/Portraits
	if dict.has("characters"):
		portraits = dict["characters"] as Dictionary

	# We expect "steps" to hold all sections/nodes
	if not dict.has("steps") or typeof(dict["steps"]) != TYPE_DICTIONARY:
		push_error("Missing 'steps' object in JSON.")
		return false

	# And a start section named "sections" 
	var steps_dict: Dictionary = dict["steps"] as Dictionary
	if not steps_dict.has("sections"):
		push_error("There is so sections step in steps :(")
		return false

	# Initialize runtime state
	data = dict
	current_node = "sections"
	line_index = 0
	return true

func is_finished() -> bool:
	# end = dialog is over
	return current_node == "end"

func get_current_line() -> Dictionary:
	var lang = TranslationServer.get_locale().substr(0, 2)
	if not data.has("steps"):
		push_error("DialogParser: JSON has no 'steps' or was not loaded correctly.")
		return {}

	if is_finished():
		return {}

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array = []
	if node.has("lines"):
		lines = node["lines"]

	if line_index >= 0 and line_index < lines.size():
		var ld: Dictionary = lines[line_index] as Dictionary
		var sp: String = String(ld.get("speaker", ""))

		var portrait_path := ""
		if portraits.has(sp):
			portrait_path = String(portraits[sp])

		if lang == "en":
			return {
				"speaker": sp,
				"text": String(ld.get("text_en", "")),
				"portrait": portrait_path
			}
		elif lang == "de":
			return {
				"speaker": sp,
				"text": String(ld.get("text_de", "")),
				"portrait": portrait_path
			}

	return {}

func next() -> void:
	# Advance to the next line in this node, or jump to the node's "next"
	# no lines left -> end
	if is_finished():
		return

	if not data.has("steps"):
		return

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array = []
	if node.has("lines"):
		lines = node["lines"]

	line_index += 1
	if line_index >= lines.size():
		current_node = String(node.get("next", "end"))
		line_index = 0

func has_choices_for_current_node() -> bool:
	if is_finished():
		return false
 
	if not data.has("steps"):
		return false

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	if not node.has("choices"):
		return false
	var choices := node.get("choices", []) as Array
	return choices.size() > 0

func get_current_choices() -> Array:
	if is_finished():
		return []

	if not data.has("steps"):
		return []

	var lang = TranslationServer.get_locale().substr(0, 2)

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var raw_choices: Array = node.get("choices", []) as Array
	
	var result: Array = []
	
	for choice in raw_choices:
		if typeof(choice) != TYPE_DICTIONARY:
			continue

		var text := ""
		if lang == "en":
			text = choice.get("text_en", "")
		elif lang == "de":
			text = choice.get("text_de", "")
		else:
			# fallback
			text = choice.get("text_en", "")

		result.append({
			"id": choice.get("id", ""),
			"text": text,
			"next": choice.get("next", "")
		})
		
	return result

func is_last_line_in_node() -> bool:
	if is_finished():
		return false

	if not data.has("steps"):
		return true

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array      = node.get("lines", []) as Array
	if lines.is_empty():
		return true
	return line_index >= (lines.size() - 1)

func choose(index: int) -> void:
	if is_finished():
		return

	if not data.has("steps"):
		return

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	if not node.has("choices"):
		return
	var choices := node.get("choices", []) as Array
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index] as Dictionary
	current_node = String(choice.get("next", "end"))
	line_index = 0

func get_current_node() -> String:
	return current_node
