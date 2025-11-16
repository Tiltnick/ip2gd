extends Control

#Game not paused anymore, menu hides
func resume():
	get_tree().paused = false
	hide()

#game pauses and menu shows
func pause():
	get_tree().paused = true
	show()

#when pressing esc and game is paused, game starts 
#when game isn't paused, it pauses --> menu opens
func esc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()




func _on_continue_button_pressed() -> void:
	resume()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menues/main_menu.tscn")


func _on_round_buttton_pressed() -> void:
	resume()
	
func _process(delta):
	esc()
