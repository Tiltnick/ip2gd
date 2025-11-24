extends CanvasLayer

func resume():
	get_tree().paused = false
	hide()
	DialogManager.show()
	hotbarglobal.hotbar.show()
		
func pause():
	get_tree().paused = true
	show()
	DialogManager.hide()
	hotbarglobal.hotbar.hide()
	


func esc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
		
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()


func _on_continue_button_pressed() -> void:
	resume()


func _on_exit_button_pressed() -> void:
	# Scene/Area im GameState merken
	var current_scene := get_tree().current_scene
	if current_scene:
		GameState.current_area_path = current_scene.get_scene_file_path()

	# Spielstand speichern
	SaveSystem.save_game()
	GameState.has_save = true

	# Spiel wieder "entpausen" für Main menu
	get_tree().paused = false

	# Zur MainMenu scene wechseln
	SceneManager.goto_main_menu()


func _on_round_buttton_pressed() -> void:
	resume()


func _process(_delta: float) -> void:
	esc()
