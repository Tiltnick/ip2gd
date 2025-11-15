extends CanvasLayer

signal choice_made(choice_id: String)

@onready var box: DialogBox = $DialogBox

# Initialize my DialogParser
var runtime: DialogParser = DialogParser.new()

func start_dialog(json_path: String) -> void:
	# Load the JSON. 
	# If Loading fails -> PANIC
	if not runtime.load_json(json_path):
		return

	# Main loop: show one line, wait for player input -> repeat
	while not runtime.is_finished():
		var line: Dictionary = runtime.get_current_line()
		if line.is_empty():
			break  # Something with the JSON is wrong

		# speaker = Person that is speaking in the dialog rn 
		var speaker: String = String(line.get("speaker", ""))
		var text: String    = String(line.get("text", ""))

		# Show the current line that is parsed trhough my typewriter
		box.show_line(speaker, text)

		# Wait until the player presses Enter AFTER the typewriter finished
		await box.continue_pressed

		# we show them and branch based on the player's selection.
		if runtime.is_last_line_in_node() and runtime.has_choices_for_current_node():
			# Build  list of button texts
			var choice_texts: Array[String] = []
			for c in runtime.get_current_choices():
				choice_texts.append(String(c.get("text", "")))

			# Show and await selection 
			box.show_choices(choice_texts)
			var selected_index: int = await box.choice_selected

			# Entscheidung auslesen, ID holen, Signal feuern und speichern
			var choices_array: Array = runtime.get_current_choices()
			if selected_index >= 0 and selected_index < choices_array.size():
				var chosen: Dictionary = choices_array[selected_index] as Dictionary
				var chosen_id: String = String(chosen.get("id", ""))

				choice_made.emit(chosen_id)
				_save_decision_to_json(chosen_id)

			# Apply the branch
			runtime.choose(selected_index)

			# Continue the while-loop 
			continue

		# Otherwise, move to the next line
		runtime.next()

	# Conversation done → hide the box
	box.hide()


# Speichert eine getroffene Entscheidung (choice_id) in user://decisions.json
func _save_decision_to_json(choice_id: String) -> void:
	var path: String = "user://choices.json"
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
