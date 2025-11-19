extends Interactable

func interact():
	print("Buch eingesammelt!")
	
	queue_free()
	GlobalMenuButton.show()
