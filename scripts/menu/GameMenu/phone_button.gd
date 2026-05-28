extends CanvasLayer

@onready var button: Button = $Control/RoundButton


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

	PhoneManager.open_phone()
