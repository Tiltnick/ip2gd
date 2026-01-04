extends AudioStreamPlayer

@onready var UI_SFX = load("res://assets/sound/sfx/ui_sound.mp3")
@onready var SUCCESS = load("res://assets/sound/sfx/Success.wav")
@onready var FAIL = load("res://assets/sound/sfx/Wrong.wav")
@onready var NOTIFICATION = load("res://assets/sound/sfx/notification.wav")
@onready var STONE_GRINDING = load("res://assets/sound/sfx/stone_grinding.wav")
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

func ui_click_sound():
	pitch_scale = 1.0
	stream = UI_SFX
	play()
	
func footstep_sound():
	stream = FOOTSTEPS.pick_random()
	pitch_scale = randf_range(footstep_pitch_min, footstep_pitch_max)
	play()

func puzzle_solved():
	pitch_scale = 1.0
	stream = SUCCESS
	play()
	
func puzzle_failed():
	pitch_scale = 1.0
	stream = FAIL
	play()
	
func notification_sound():
	pitch_scale = 1.0
	stream = NOTIFICATION
	play()

func stone_grinding():
	pitch_scale = 1.0
	stream = STONE_GRINDING
	play()
