extends CanvasLayer

@onready var button: Button = $Control/RoundButtton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(_on_pressed)
	update_visibility()


func update_visibility() -> void:
	visible = bool(GameState.puzzle_state.get("phone", false))
	print("PhoneButton scene visible: ", visible)


func _on_pressed() -> void:
	if not bool(GameState.puzzle_state.get("phone", false)):
		return

	var phone_ui = get_tree().get_first_node_in_group("phone_ui")

	if phone_ui == null:
		print("PhoneButton: PhoneUI nicht gefunden.")
		return

	if phone_ui.has_method("open_phone"):
		phone_ui.open_phone()
