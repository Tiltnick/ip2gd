extends AudioStreamPlayer


func _ready() -> void:
	bus = "Music"
	


func bgm_main_menu():
	stream = load("res://assets/sound/bgm/Strange_Worlds.wav")
	play()

func bgm_spaceship():
#	stream = load()
	play()
