extends AudioStreamPlayer

const MAIN_MENU = "res://assets/sound/bgm/Strange_Worlds.ogg"
const SPACE_SHIP ="res://assets/sound/bgm/Sunlight_Through_Leaves.ogg"
const OUTSIDE_1 = "res://assets/sound/bgm/Golden_Gleam.ogg"
const OUTSIDE_2 = "res://assets/sound/bgm/Gymnopedie_No.1.ogg"
const OUTSIDE_3 = "res://assets/sound/bgm/Wanderers_Tale.ogg"
const OUTSIDE_4 = "res://assets/sound/bgm/Floating_Dream.ogg"
const CAVE = "res://assets/sound/bgm/Polar_Lights.ogg"
const TEMPLE = "res://assets/sound/bgm/Gentle_Breeze.ogg"


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
	
func bgm_outside4():
	stream = load(OUTSIDE_4)
	play()
	
func bgm_cave():
	stream = load(CAVE)
	play()
	
func bgm_temple():
	stream = load(TEMPLE)
	play()	
	

	
	
