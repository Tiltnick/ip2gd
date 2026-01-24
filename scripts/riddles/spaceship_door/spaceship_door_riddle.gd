extends CanvasLayer

@export var code: Array[String] = ["1", "1", "1", "1"]

@onready var inputs: Array[LineEdit] = [
	$Control/Panel2/HBoxContainer/Input1,
	$Control/Panel2/HBoxContainer/Input2,
	$Control/Panel2/HBoxContainer/Input3,
	$Control/Panel2/HBoxContainer/Input4
]

@onready var title_label: Label = $Control/Panel2/Label
@onready var enter_button: Button = $Control/Panel2/EnterButton

signal code_verified(result: bool)

var code_solved: bool = false


func _ready() -> void:
	enter_button.pressed.connect(_on_button_pressed)

	for input in inputs:
		input.focus_mode = Control.FOCUS_ALL
		input.max_length = 1
		input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		input.text_changed.connect(_on_text_changed.bind(input))
		input.gui_input.connect(_on_input_gui.bind(input))

	call_deferred("_focus_input", 0)


func _focus_input(i: int) -> void:
	if i < 0 or i >= inputs.size():
		return
	var le: LineEdit = inputs[i]
	le.grab_focus()
	le.select_all() 
	le.caret_column = le.text.length()


func _on_text_changed(new_text: String, input: LineEdit) -> void:
	#wenn ein zeichen eingeben, dann ins nächste eingabefeld springen 
	if new_text.length() == 1:
		var idx := inputs.find(input)
		if idx != -1 and idx < inputs.size() - 1:
			_focus_input(idx + 1)


func _on_input_gui(event: InputEvent, input: LineEdit) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var idx := inputs.find(input)
	if idx == -1:
		return

	#mit backspace ins feld zurück 
	if event.keycode == KEY_BACKSPACE:
		if input.text == "" and idx > 0:
			var prev: LineEdit = inputs[idx - 1]
			prev.text = ""
			_focus_input(idx - 1)
			get_viewport().set_input_as_handled()
		return

	# enter im letzten feld heißt überprüfen 
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		if idx == inputs.size() - 1:
			_on_button_pressed()
			get_viewport().set_input_as_handled()
		return


func _on_button_pressed() -> void:
	if code_solved:
		return

	var lang := TranslationServer.get_locale().substr(0, 2)

	var entered: Array[String] = []
	for input in inputs:
		entered.append(input.text)

	if entered == code:
		title_label.text = "Code Verified" if lang == "en" else "Code verifiziert"
		title_label.modulate = Color.CHARTREUSE

		GameState.puzzle_state["ship_exit_monologue_pending"] = true
		await get_tree().create_timer(0.7).timeout

		code_solved = true
		code_verified.emit(true)
	else:
		title_label.text = "Error"
		title_label.modulate = Color.BLACK
		code_verified.emit(false)


func _on_exit_pressed() -> void:
	hide()


func _on_round_buttton_pressed() -> void:
	hide()
	
	
	
