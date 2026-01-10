extends AudioStreamPlayer

@onready var UI_SFX = load("res://assets/sound/sfx/ui_sound.mp3")
@onready var SUCCESS = load("res://assets/sound/sfx/Success.wav")
@onready var FAIL = load("res://assets/sound/sfx/Wrong.wav")
@onready var NOTIFICATION = load("res://assets/sound/sfx/Notification.wav")



func _ready() -> void:
	bus = "SFX"

func ui_click_sound():
	stream = UI_SFX
	play()

func puzzle_solved():
	stream = SUCCESS
	play()
	
func puzzle_failed():
	stream = FAIL
	play()
	
func notification_sfx():
	stream = NOTIFICATION
	play()
