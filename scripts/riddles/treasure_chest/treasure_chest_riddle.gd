extends CanvasLayer

@export var code = ["1", "1", "1"]

@onready var title_label = $Control/Panel2/Label

@onready var inputs = [
	$Control/Panel2/HBoxContainer/Input1,
	$Control/Panel2/HBoxContainer/Input2,
	$Control/Panel2/HBoxContainer/Input3
]

signal code_verified(result: bool)
var code_solved := false


func _ready():
	var lang = TranslationServer.get_locale().substr(0, 2)
	
	for input in inputs:
		input.max_length = 1
		input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
		input.text_changed.connect(_on_text_changed.bind(input))
		
		if lang == "de":
			title_label.text = "Um hier zu passieren muss der Spieler die Menge der \n verschieden Käfer finden, die in der Wüste spazieren!"
		if lang == "en":
			title_label.text = "To pass here the player has to guess the amount of bugs \n which are crawling in this desert!"
		print("Test test")


func _on_text_changed(new_text: String, input: LineEdit) -> void:
	# Fokus weitergeben
	if new_text.length() == 1:
		var index := inputs.find(input)
		if index != -1 and index < inputs.size() - 1:
			inputs[index + 1].grab_focus()

	# Nach jeder Eingabe prüfen
	_try_verify_code()


func _try_verify_code() -> void:
	if code_solved:
		return

	# Prüfen ob alle Felder gefüllt sind
	for input in inputs:
		if input.text.length() != 1:
			return

	var entered: Array = []
	for input in inputs:
		entered.append(input.text)

	if entered == code:
		code_solved = true
		GameState.puzzle_state["ship_exit_monologue_pending"] = true
		emit_signal("code_verified", true)


func _on_round_buttton_pressed() -> void:
	hide()
