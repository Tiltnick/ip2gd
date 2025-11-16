extends Control

@onready var pop_up = $PopUp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_new_g_button_pressed() -> void:
	pop_up.open(
		"New Game?",
		func(): start_new_game() 
	)

func _on_resume_button_pressed() -> void:
	print("pressed resume") #funktion muss noch rein wenn gespeichert
	#oder raus wenn speichern erst im nächsten sprint

func _on_exit_button_pressed() -> void:
	pop_up.open(
		"Exit Game?",
		func(): exit_game()
	)



func _on_insta_button_pressed() -> void:
	OS.shell_open("https://www.instagram.com/oris.is.here?igsh=MXUxNGN5NDc0YTlybQ%3D%3D&utm_source=qr")


func _on_discord_button_pressed() -> void:
	OS.shell_open("https://discord.gg/NUBAuVsp")


#TODO func _on_settings_button_pressed() -> void:
#TODO 	get_tree().change_scene_to_file()

func start_new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/maps/spaceship.tscn")
#TODO link to start scene

func exit_game() -> void:
	get_tree().quit()
