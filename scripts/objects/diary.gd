extends Interactable

func interact():
	print("Buch eingesammelt!")

	# später kommt hier: hotbar.add_item(self.book_id)
	
	# Buch verschwindet
	queue_free()
	GlobalMenuButton.show()
