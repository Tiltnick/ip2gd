extends Control

@onready var pop_up = $PopUp

@onready var resume_button: Button = $VBoxContainer/ResumeButton

func _ready() -> void:
	# Prüft ob es eine Save-Datei gibt -> Nein = button.disabled
	resume_button.disabled = not FileAccess.file_exists(SaveSystem.SAVE_PATH)
	WorldAudioManager.play_bgm(load("res://assets/sound/Cozy Tunes (Pro) v1.4/Cozy Tunes (Pro)/Audio/wav/Tracks/Forgotten Biomes.wav"))

func _on_new_g_button_pressed() -> void:
	play_button_sound()
	pop_up.open(
		"New Game?",
		func(): start_new_game()
		
	)
	


func _on_resume_button_pressed() -> void:
	play_button_sound()
	# Speicherstand aus GameState
	var loaded := SaveSystem.load_game()
	if loaded and GameState.has_save:
		get_tree().paused = false
		# Scene über scene manager starten
		SceneManager.goto_scene(GameState.current_area_path, "start")
	else:
		print("Kein gültiger Spielstand zum Fortsetzen.")


func _on_exit_button_pressed() -> void:
	play_button_sound()
	pop_up.open(
		"Exit Game?",
		func(): exit_game()
	)


func _on_insta_button_pressed() -> void:
	play_button_sound()
	OS.shell_open("https://www.instagram.com/oris.is.here?igsh=MXUxNGN5NDc0YTlybQ%3D%3D&utm_source=qr")


func _on_discord_button_pressed() -> void:
	play_button_sound()
	OS.shell_open("https://discord.gg/jRj5tqUYKx")


# Startet ein neues Spiel
func start_new_game() -> void:
	# GameState zurücksetzen
	GameState.current_area_path = "res://scenes/maps/spaceship.tscn"
	GameState.puzzle_items = []
	GameState.puzzle_state = {}
	GameState.has_save = false
	GameState.picked_items = []

	# Hotbar + Inventory zurücksetzen
	hotbarglobal.hotbar_items.fill(null)
	hotbarglobal.inventory_items.fill(null)

	# UI updaten wenn bereits existiert
	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.update_slots()

	if hotbarglobal.inventory:
		hotbarglobal.inventory.update_slots()

	get_tree().paused = false

	# Intro starten
	GameState.should_play_intro_dialog = true

	# Szene beginnen
	SceneManager.goto_scene("res://scenes/maps/spaceship.tscn", "start")

	


func exit_game() -> void:
	play_button_sound()
	get_tree().quit()

func play_button_sound():
	WorldAudioManager.play_sfx(load("res://assets/sound/sfx/ui_sound.mp3"))
