extends Control

@onready var pop_up = $PopUp

@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _ready() -> void:
# Prüft ob es eine Save-Datei gibt -> Nein = button.disabled
	resume_button.disabled = not FileAccess.file_exists(SaveSystem.SAVE_PATH)



func _on_new_g_button_pressed() -> void:
	pop_up.open(
		"New Game?",
		func(): start_new_game()
	)


func _on_resume_button_pressed() -> void:
# Lädt Speicherstand aus GameState
	var loaded := SaveSystem.load_game()
	if loaded and GameState.has_save:
		get_tree().change_scene_to_file(GameState.current_area_path)
	else:
		print("Kein gültiger Spielstand zum Fortsetzen.")
		


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
# GameState wird gecleart
	GameState.current_area_path = "res://scenes/maps/spaceship.tscn"
	GameState.puzzle_state = {}
	GameState.has_save = false

	get_tree().change_scene_to_file("res://scenes/maps/spaceship.tscn")


func exit_game() -> void:
	get_tree().quit()
