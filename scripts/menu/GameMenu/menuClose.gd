extends CanvasLayer

# hier drauf hören alle tabs im menu für closeButton!
func close_menu():
	visible = false
	get_tree().paused = false
	GlobalMenuButton.show()
	SettingsButton.show()
	hotbarglobal.hotbar.show()
