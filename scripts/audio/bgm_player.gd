extends AudioStreamPlayer

const MAIN_MENU = "res://assets/sound/bgm/Strange_Worlds.wav"
const SPACE_SHIP ="res://assets/sound/bgm/Sunlight_Through_Leaves.wav"
const OUTSIDE_1 = "res://assets/sound/bgm/Golden_Gleam.wav"
const OUTSIDE_2 = "res://assets/sound/bgm/Gymnopedie_No.1.wav"
const OUTSIDE_3 = "res://assets/sound/bgm/Wanderers_Tale.wav"
const CAVE = "res://assets/sound/bgm/Polar_Lights.wav"
func _ready() -> void:
	bus = "Music"
	


func bgm_main_menu():
	stream = load(MAIN_MENU)
	play()

func bgm_spaceship():
	stream = load(SPACE_SHIP)
	play()
	
func bgm_outside1():
	stream = load(OUTSIDE_1)
	play()
	
func bgm_outside2():
	stream = load(OUTSIDE_2)
	play()
	
func bgm_outside3():
	stream = load(OUTSIDE_3)
	play()
	
func bgm_cave():
	stream = load(CAVE)
	play()
