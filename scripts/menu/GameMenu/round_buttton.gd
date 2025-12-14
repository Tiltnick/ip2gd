extends Button

func _on_pressed() -> void:
	get_tree().paused = true
	GlobalMenuButton.hide()
	SettingsButton.hide()
	GameMenu.show()
	hotbarglobal.hotbar.hide()
	SfxPlayer.ui_click_sound()
