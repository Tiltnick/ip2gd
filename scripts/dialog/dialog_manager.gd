extends CanvasLayer

signal choice_made(choice_id: String)
signal dialog_finished
signal dialog_started

@onready var box: DialogBox = $DialogBox

# Initialize my DialogParser
var runtime: DialogParser = DialogParser.new()

var is_running: bool = false # NEU


func _ready() -> void:
	hide()


func start_dialog(json_path: String) -> void:
	is_running = true  # NEU
	show()
	# Load the JSON. 
	# If Loading fails -> PANIC
	#signal 
	dialog_is_started()
	if not runtime.load_json(json_path):
		is_running = false  # NEU
		return

	# Main loop: show one line, wait for player input -> repeat
	while not runtime.is_finished():
		var line: Dictionary = runtime.get_current_line()
		if line.is_empty():
			break

		var speaker: String = String(line.get("speaker", ""))
		var text: String    = String(line.get("text", ""))
		var portrait_path: String = String(line.get("portrait", ""))

		box.show_line(speaker, text, portrait_path)

		await box.continue_pressed

		if runtime.is_last_line_in_node() and runtime.has_choices_for_current_node():
			
			var choice_texts: Array[String] = []
			for c in runtime.get_current_choices():
				choice_texts.append(String(c.get("text", "")))

			box.show_choices(choice_texts)
			var selected_index: int = await box.choice_selected

			var choices_array: Array = runtime.get_current_choices()
			if selected_index >= 0 and selected_index < choices_array.size():
				var chosen: Dictionary = choices_array[selected_index] as Dictionary
				var chosen_id: String = String(chosen.get("id", ""))

				choice_made.emit(chosen_id)
				Choice_Store.add_choice_id(chosen_id)

			runtime.choose(selected_index)
			continue

		runtime.next()
	dialog_is_finished()
	

func dialog_is_finished():
	box.hide()
	emit_signal("dialog_finished")
	is_running = false # NEU
	hide()
	
func dialog_is_started():
	emit_signal("dialog_started")
