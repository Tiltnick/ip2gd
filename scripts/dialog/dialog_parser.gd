extends Node
class_name DialogParser

var data: Dictionary = {}

# Name of the current section inside the JSON (dialog starts with "sections" and ends with "end")
var current_node: String = ""

# Index of the current line within the node's "lines" array
var line_index: int = 0

func load_json(path: String) -> bool:
	# Read the JSON file as a string and parse it
	var json: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(json)
	if typeof(parsed) != TYPE_DICTIONARY:
		# %s path will be print out as a string so you can see which json is broken
		push_error("Invalid JSON: %s" % path)
		return false

	var dict: Dictionary = parsed as Dictionary

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
	if is_finished():
		return {}

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array      = node.get("lines", []) as Array

	if line_index >= 0 and line_index < lines.size():
		var ld: Dictionary = lines[line_index] as Dictionary
		return {
			"speaker": String(ld.get("speaker", "")),
			"text": String(ld.get("text", ""))
		}

	return {}

func next() -> void:
	# Advance to the next line in this node, or jump to the node's "next"
	# no lines left -> end
	if is_finished():
		return

	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array      = node.get("lines", []) as Array

	line_index += 1
	if line_index >= lines.size():
		current_node = String(node.get("next", "end"))
		line_index = 0
