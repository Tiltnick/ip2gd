extends Control

@export var code = ["1", "1", "1", "x"]

@onready var inputs = [
	$Panel2/HBoxContainer/Input1,
	$Panel2/HBoxContainer/Input2,
	$Panel2/HBoxContainer/Input3,
	$Panel2/HBoxContainer/Input4	
]

@onready var title_label = $Panel2/Label
signal code_verified(result: bool)

func _ready():
	$Panel2/EnterButton.pressed.connect(_on_button_pressed)
	
	position = (get_viewport_rect().size - size) / 2
	
	for input in inputs:
		input.max_length = 1
		input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		input.text_changed.connect(_on_text_changed.bind(input))

func _on_text_changed(new_text: String, input: LineEdit):
	if new_text.length() > 0:
		var char = new_text[-1]
		if not char.is_valid_int():
			input.text = ""
		elif new_text.length() > 1:
			input.text = new_text[-1]

func _on_button_pressed():
	var entered = []
	for input in inputs:
		entered.append(input.text)

	if entered == code:
		title_label.text = "Access Granted"
		title_label.modulate = Color.GREEN
		emit_signal("code_verified", true)
		await get_tree().create_timer(0.3).timeout
		hide()
	else:
		title_label.text = "Error"
		title_label.modulate = Color.BLACK
		emit_signal("code_verified", false)


func _on_exit_pressed() -> void:
	hide()
