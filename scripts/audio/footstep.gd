extends AudioStreamPlayer

@onready var FOOTSTEPS := [
	load("res://assets/sound/sfx/footsteps/Dirt Path Footstep 1.wav"),
	load("res://assets/sound/sfx/footsteps/Dirt Path Footstep 2.wav"),
	load("res://assets/sound/sfx/footsteps/Dirt Path Footstep 3.wav"),
	load("res://assets/sound/sfx/footsteps/Dirt Path Footstep 4.wav")
]
@export var footstep_pitch_min := 0.95
@export var footstep_pitch_max := 1.05

func _ready() -> void:
	bus = "SFX"

func footstep_sound():
	stream = FOOTSTEPS.pick_random()
	pitch_scale = randf_range(footstep_pitch_min, footstep_pitch_max)
	play()
