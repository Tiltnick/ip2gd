extends Node2D

@export var flashlight_save_id: String = "flashlight_obtained"

@onready var field_of_view: PointLight2D = $Field_of_view


func _ready() -> void:
	if hotbarglobal.inventory_items.has("flashlight"):
		GameState.puzzle_state[flashlight_save_id] = true
		field_of_view.visible = true
		return

	field_of_view.visible = false

	DialogManager.start_dialog(
		"res://dialog/innerMonologue/entering_cave.json"
	)

	await DialogManager.dialog_finished
	exit_scene()


func exit_scene() -> void:
	SceneManager.goto_scene(
		"res://scenes/maps/Outside_2/outside_2.tscn",
		"from_sams_cave"
	)


func configure_camera(cam: Camera2D) -> void:
	cam.limit_left = -720
	cam.limit_right = 750
	cam.limit_top = -775
	cam.limit_bottom = 200
