extends Control

@onready var darkness: ColorRect = $Dark
@onready var mat: ShaderMaterial = darkness.material as ShaderMaterial

@export var radius := 140.0
@export var softness := 80.0
@export var darkness_alpha := 1.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("softness", softness)
	mat.set_shader_parameter("darkness_alpha", darkness_alpha)

func _process(_delta: float) -> void:
	var mpos: Vector2 = get_viewport().get_mouse_position()
	var vsize: Vector2 = get_viewport().get_visible_rect().size

	# UV (0..1)
	var muv := mpos / vsize
	mat.set_shader_parameter("light_uv", muv)
