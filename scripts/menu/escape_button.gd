extends Button

func _open_exit_popup():
	var popup = GlobalUI.get_node("PopUp")

	var lang = TranslationServer.get_locale().substr(0, 2)

	if lang == "en":
		popup.open("Exit Game?", func(): get_tree().quit())
	else:
		popup.open("Spiel verlassen?", func(): get_tree().quit())


func _on_pressed() -> void:
	var scene := get_tree().current_scene
	
	if scene and scene.name == "MainMenu":
		_open_exit_popup()
	else:
		SavingMenu.toggle_pause()
