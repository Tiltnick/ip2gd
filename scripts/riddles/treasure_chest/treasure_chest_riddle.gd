extends CanvasLayer

@export var code: Array[String] = ["1", "1", "1"]
@export var auto_close_delay: float = 1.0  

@onready var title_label: Label = $Control/Panel2/Label

@onready var inputs: Array[LineEdit] = [
	$Control/Panel2/HBoxContainer/Input1,
	$Control/Panel2/HBoxContainer/Input2,
	$Control/Panel2/HBoxContainer/Input3
]

signal code_verified(result: bool)
var code_solved: bool = false


func _ready() -> void:
	var lang := TranslationServer.get_locale().substr(0, 2)

	if lang == "de":
		title_label.text = "Um hier zu passieren muss der Spieler die Menge der \nverschieden Käfer finden, die in der Wüste spazieren!"
	else:
		title_label.text = "To pass here the player has to guess the amount of bugs \nwhich are crawling in this desert!"

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
	# ins nächste feld springen
	if new_text.length() == 1:
		var idx := inputs.find(input)
		if idx != -1 and idx < inputs.size() - 1:
			_focus_input(idx + 1)

	_try_verify_code()


func _on_input_gui(event: InputEvent, input: LineEdit) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var idx := inputs.find(input)
	if idx == -1:
		return

	# backspace
	if event.keycode == KEY_BACKSPACE:
		if input.text == "" and idx > 0:
			var prev: LineEdit = inputs[idx - 1]
			prev.text = ""
			_focus_input(idx - 1)
			get_viewport().set_input_as_handled()
		return


func _try_verify_code() -> void:
	if code_solved:
		return

	# prüfen ob alle felder zeichen haben
	for input in inputs:
		if input.text.length() != 1:
			return

	var entered: Array[String] = []
	for input in inputs:
		entered.append(input.text)

	if entered == code:
		code_solved = true
		emit_signal("code_verified", true)

		
		for input in inputs:
			input.editable = false

		
		call_deferred("_delayed_close")
	else:
		emit_signal("code_verified", false)


func _delayed_close() -> void:
	await get_tree().create_timer(auto_close_delay).timeout
	hide()


func _on_round_buttton_pressed() -> void:
	hide()
