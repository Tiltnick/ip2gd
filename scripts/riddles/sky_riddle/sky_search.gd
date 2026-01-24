extends Control

@onready var darkness: ColorRect = $Dark
@onready var mat: ShaderMaterial = darkness.material as ShaderMaterial
@onready var close_button: Button = $close_button

@export var radius := 140.0
@export var softness := 80.0
@export var darkness_alpha := 1.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("softness", softness)
	mat.set_shader_parameter("darkness_alpha", darkness_alpha)

	
	if not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)

func _process(_delta: float) -> void:

	var mpos: Vector2 = get_viewport().get_mouse_position()
	var vsize: Vector2 = get_viewport().get_visible_rect().size
	if vsize.x <= 0.0 or vsize.y <= 0.0:
		return

	var muv: Vector2 = mpos / vsize
	mat.set_shader_parameter("light_uv", muv)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		exit_scene()

func _on_close_button_pressed() -> void:
	exit_scene()

func exit_scene() -> void:
	if GameState.return_scene_path != "":
		SceneManager.goto_scene(GameState.return_scene_path, "start")
	else:
		print("Kein return_scene_path gesetzt!")
