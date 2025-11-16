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
	var lines: Array = []
	if node.has("lines"):
		lines = node["lines"]

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
	var lines: Array = []
	if node.has("lines"):
		lines = node["lines"]

	line_index += 1
	if line_index >= lines.size():
		current_node = String(node.get("next", "end"))
		line_index = 0

# Returns true if the current node has a non-empty "choices" array.
func has_choices_for_current_node() -> bool:
	if is_finished():
		return false
	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	if not node.has("choices"):
		return false
	var choices := node.get("choices", []) as Array
	return choices.size() > 0

# Returns the raw "choices" array for the current node (array of dictionaries).
# Each entry commonly has: { "text": String, "next": String }
func get_current_choices() -> Array:
	if is_finished():
		return []
	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	return node.get("choices", []) as Array

# Returns true if the current line_index points to the last line of the node.
func is_last_line_in_node() -> bool:
	if is_finished():
		return false
	var steps: Dictionary = data["steps"] as Dictionary
	var node: Dictionary  = steps.get(current_node, {}) as Dictionary
	var lines: Array      = node.get("lines", []) as Array
	if lines.is_empty():
		# If there are no lines, we consider it "last" so that choices can still show.
		return true
	return line_index >= (lines.size() - 1)

# Pick a choice by index
func choose(index: int) -> void:
	if is_finished():
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

# *** NEU: einfacher Getter, damit der DialogManager den aktuellen Node kennt
func get_current_node() -> String:
	return current_node
