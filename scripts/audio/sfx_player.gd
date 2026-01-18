extends AudioStreamPlayer

@onready var UI_SFX = load("res://assets/sound/sfx/ui_sound.mp3")
@onready var SUCCESS = load("res://assets/sound/sfx/Success.wav")
@onready var FAIL = load("res://assets/sound/sfx/Wrong.wav")
@onready var NOTIFICATION = load("res://assets/sound/sfx/notification.wav")
@onready var NOTIFICATION2 = load("res://assets/sound/sfx/notification2.wav")
@onready var STONE_GRINDING = load("res://assets/sound/sfx/stone_grinding.wav")


func _ready() -> void:
	bus = "SFX"

func ui_click_sound():
	pitch_scale = 1.0
	stream = UI_SFX
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

func notification_quest_sound():
	pitch_scale = 1.0
	stream = NOTIFICATION2
	play()

func stone_grinding():
	pitch_scale = 1.0
	stream = STONE_GRINDING
	play()
