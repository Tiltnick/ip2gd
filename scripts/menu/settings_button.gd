extends Button



func _on_pressed() -> void:
	get_tree().paused = true
	GlobalMenuButton.hide()
	SettingsButton.hide()
	SettingsMenu.show()
