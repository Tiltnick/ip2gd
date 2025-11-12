extends CanvasLayer

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

			# Apply the branch
			runtime.choose(selected_index)

			# Continue the while-loop 
			continue

		# Otherwise, move to the next line
		runtime.next()

	# Conversation done → hide the box
	box.hide()
