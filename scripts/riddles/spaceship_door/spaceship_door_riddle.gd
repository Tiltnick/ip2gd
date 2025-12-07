extends CanvasLayer

@export var code = ["1", "1", "1", "1"]

@onready var inputs = [
	$Control/Panel2/HBoxContainer/Input1,
	$Control/Panel2/HBoxContainer/Input2,
	$Control/Panel2/HBoxContainer/Input3,
	$Control/Panel2/HBoxContainer/Input4
]

@onready var title_label = $Control/Panel2/Label
signal code_verified(result: bool)

var code_solved: bool = false


func _ready():
	$Control/Panel2/EnterButton.pressed.connect(_on_button_pressed)

	for input in inputs:
		input.max_length = 1
		input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		input.text_changed.connect(_on_text_changed.bind(input))


func _on_text_changed(new_text: String, input: LineEdit) -> void:
	# Sobald EIN Zeichen eingegeben wurde → weiter springen
	if new_text.length() == 1:
		var index := inputs.find(input)
		if index != -1 and index < inputs.size() - 1:
			inputs[index + 1].grab_focus()


func _on_button_pressed() -> void:
	if code_solved:
		return

	var entered: Array = []
	for input in inputs:
		entered.append(input.text)

	if entered == code:
		title_label.text = "Code Verified"
		title_label.modulate = Color.CHARTREUSE
		
		await get_tree().create_timer(1.5).timeout
		code_solved = true
		emit_signal("code_verified", true)
	else:
		title_label.text = "Error"
		title_label.modulate = Color.BLACK
		emit_signal("code_verified", false)


func _on_exit_pressed() -> void:
	hide()


func _on_round_buttton_pressed() -> void:
	hide()
