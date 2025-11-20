extends CanvasLayer

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func esc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()


func _on_continue_button_pressed() -> void:
	resume()


func _on_exit_button_pressed() -> void:
	# 1. aktuelle Szene/Area im GameState merken
	var current_scene := get_tree().current_scene
	if current_scene:
		GameState.current_area_path = current_scene.get_scene_file_path()

	# 2. Spielstand speichern
	SaveSystem.save_game()

	# 3. Spiel wieder "entpausen", damit MainMenu normal läuft
	get_tree().paused = false

	# 4. Zur MainMenu-Szene wechseln
	get_tree().change_scene_to_file("res://scenes/Menues/main_menu.tscn")


func _on_round_buttton_pressed() -> void:
	resume()


func _process(delta: float) -> void:
	esc()
