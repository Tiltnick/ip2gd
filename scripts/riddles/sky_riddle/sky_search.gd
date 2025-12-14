extends Control

@onready var darkness: ColorRect = $Dark
@onready var mat: ShaderMaterial = darkness.material as ShaderMaterial

@export var radius := 140.0
@export var softness := 80.0
@export var darkness_alpha := 1.0

func _ready() -> void:
	# Damit die Maus sichtbar bleibt (optional)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("softness", softness)
	mat.set_shader_parameter("darkness_alpha", darkness_alpha)

func _process(_delta: float) -> void:
	# Mausposition in SCREEN-Pixeln
	var mpos: Vector2 = get_viewport().get_mouse_position()
	mat.set_shader_parameter("light_pos", mpos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC
		# verhindert, dass dein normales ESC-Menü noch reagiert
		get_viewport().set_input_as_handled()

		if GameState.return_scene_path != "":
			SceneManager.goto_scene(GameState.return_scene_path, "start")
		else:
			print("Kein return_scene_path gesetzt!")
