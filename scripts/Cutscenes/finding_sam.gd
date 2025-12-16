extends Control

@onready var close_button: Button = $close_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.start_dialog("res://dialog/innerMonologue/discovering_sams_body.json")
	
	if not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed() -> void:
	exit_scene()

func exit_scene() -> void:
	if GameState.return_scene_path != "":
		SceneManager.goto_scene(GameState.return_scene_path, "start")
	else:
		print("Kein return_scene_path gesetzt!")
