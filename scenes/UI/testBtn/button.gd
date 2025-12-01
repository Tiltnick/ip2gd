extends Button

# Test-Button kann in Szenen welche im Szenenmanager stehen eingefügt und getestet werden (zB Spaceship)
# Beim klick auf den Button wird das pop up visible gestellt und die Animation startet
# mit PopupManager.popup_show() wird Pop Up aufgerufen

func _on_pressed():
	PopupManager.popup_show()
	
