extends CanvasLayer

func _ready() -> void:
	hide()   # Menü beim Start verstecken


func resume():
	get_tree().paused = false
	hide()

	# Dialog wieder einblenden nur wenn er existiert
	# (DialogManager ist ein Autoload → direkt nutzbar)
	DialogManager.show()

	# Hotbar wieder zeigen wenn sie existiert
	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.show()
		

func pause():
	get_tree().paused = true
	show()

	# Dialog versteckenfalls vorhanden
	DialogManager.hide()

	# Hotbar verstecken falls vorhanden
	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.hide()
	


func toggle_pause():
	if get_tree().paused == false:
		pause()
	else:
		resume()


func esc():
	# ESC toggelt einfach das Menü
	# Startmenü ausnehmen (Name ggf. anpassen, falls deine MainScene anders heißt)
	var current_scene := get_tree().current_scene
	if current_scene and current_scene.name == "MainMenu":
		return

	if Input.is_action_just_pressed("esc"):
		toggle_pause()


func _on_continue_button_pressed() -> void:
	resume()


func _on_exit_button_pressed() -> void:
	# Scene/Area im GameState merken
	var current_scene := get_tree().current_scene
	if current_scene:
		GameState.current_area_path = current_scene.get_scene_file_path()

	# Spielstand speichern
	SaveSystem.save_game()
	print("Spiel gespeichert")
	GameState.has_save = true

	# Laufenden Dialog  beenden
	DialogManager.force_close()

	# Spiel wieder "entpausen" für Main menu
	get_tree().paused = false

	# Menü direkt ausblenden, damit es im Hauptmenü nicht sichtbar bleibt
	hide()

	# Zur MainMenu scene wechseln
	SceneManager.goto_main_menu()


func _on_round_buttton_pressed() -> void:
	resume()


func _process(_delta: float) -> void:
	esc()
